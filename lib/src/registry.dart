import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

import 'blake2b/blake2b_hash.dart';
import 'skydb.dart';
import 'config.dart';

final unencodedPath = '/skynet/registry';

class RegistryValue {
  Uint8List tweak;
  Uint8List data;
  int revision;

  RegistryValue({this.tweak, this.data, this.revision});

  Uint8List hash() {


    final list = Uint8List.fromList([
      ...tweak,
      ...withPadding(data.length),
      ...data,
      ...withPadding(revision),
    ]);

    return Blake2bHash.hashWithDigestSize(
      256,
      list,
    );
  }
}

class SignedRegistryValue {
  RegistryValue value;
  Signature signature;

  SignedRegistryValue({this.value, this.signature});
}

Future<SignedRegistryValue> lookupRegistry(
  User user,
  FileID fileID,
) async {

  final uri = Uri.https(SkynetConfig.host, unencodedPath, {
    'publickey': 'ed25519:${user.id}',
    'fileid': hex.encode(utf8.encode(json.encode(
      fileID.toJson(),
    ))),
  });

  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final data = json.decode(res.body);

    return SignedRegistryValue(
      value: RegistryValue(
        tweak: hex.decode(data['tweak']),
        data: hex.decode(data['data']),
        revision: data['revision'],
      ),
      signature:
          Signature(hex.decode(data['signature']), publicKey: user.publicKey),
    );
  } else if (res.statusCode == 404) {
    return null;
  }
  throw Exception('unexpected response status code ${res.statusCode}');
}

Future<bool> updateRegistry(
  User user,
  FileID fileID,
  SignedRegistryValue srv,
) async {
  final uri = Uri.https(SkynetConfig.host, unencodedPath);


  final res = await http.post(uri,
      body: json.encode({
        'publickey': {
          'algorithm': 'ed25519',
          'key': user.publicKey.bytes,
        },
        'fileid': fileID.toJson(),
        'revision': srv.value.revision,
        'data': srv.value.data,
        'signature': srv.signature.bytes,
      }));



  if (res.statusCode == 204) {
    return true;
  }
  throw Exception('unexpected response status code ${res.statusCode}');
}
