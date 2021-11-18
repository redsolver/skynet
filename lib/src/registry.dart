import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart' hide MacAlgorithm;
import 'package:skynet/src/sia.dart';
import 'package:skynet/src/utils/prefix.dart';

import 'registry_classes.dart';
import 'client.dart';
import 'crypto.dart';
import 'user.dart';

final unencodedPath = '/skynet/registry';
final ed25519 = Ed25519();

Future<SignedRegistryEntry?> getEntry(
  SkynetUser user,
  String? datakey, {
  String? hashedDatakey,
  int timeoutInSeconds = 10,
  bool verifySignature = true,
  required SkynetClient skynetClient,
}) async {
  final uri = Uri.https(skynetClient.portalHost, unencodedPath, {
    'publickey': 'ed25519:${user.id}',
    'datakey': hashedDatakey ??
        hex.encode(hashDatakey(
            datakey!)) /* hex.encode(utf8.encode(json.encode(
      fileID.toJson(),
    ))) */
    ,
  });
  //print(uri);

  try {
    final res = await skynetClient.httpClient
        .get(
          uri,
          headers: skynetClient.headers,
        )
        .timeout(Duration(seconds: timeoutInSeconds));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      final srv = SignedRegistryEntry(
        entry: RegistryEntry(
          datakey: datakey,
          data: hex.decode(data['data']) as Uint8List,
          revision: data['revision'] > 9007199254740991
              ? -3 // TODO better response
              : data['revision'],
        ),
        signature:
            Signature(hex.decode(data['signature']), publicKey: user.publicKey),
      );

      // TODO Verify even with hashedDatakey
      if (hashedDatakey != null) return srv;

      if (verifySignature) {
        final verified =
            await ed25519.verify(srv.entry.hash(), signature: srv.signature!);

        if (!verified) throw Exception('Invalid signature found');
      }

      return srv;
    } else if (res.statusCode == 404) {
      return null;
    }
    throw Exception('unexpected response status code ${res.statusCode}');
  } catch (e, st) {
    // print(e);
    // print(st);
    return null;
  }
}

Future<bool> setEntryHelper(
  SkynetUser user,
  String? datakey,
  Uint8List value, {
  String? hashedDatakey,
  int? revision,
  required SkynetClient skynetClient,
}) async {
  if (revision == null) {
    SignedRegistryEntry? existing;

    try {
      // fetch the current value to find out the revision
      final res = await getEntry(
        user,
        datakey,
        hashedDatakey: hashedDatakey,
        skynetClient: skynetClient,
      );

      existing = res;
    } catch (e) {
      existing = null;
    }
    revision = (existing?.entry.revision ?? 0) + 1;
  }

  // build the registry value
  final rv = RegistryEntry(
    datakey: datakey,
    data: value,
    revision: revision,
  );

  if (hashedDatakey != null) {
    rv.hashedDatakey = Uint8List.fromList(hex.decode(hashedDatakey));
  }

  // sign it
  final sig = await user.sign(rv.hash());

  final srv = SignedRegistryEntry(signature: sig, entry: rv);

  // update the registry
  final updated = await setEntryRaw(
    user,
    datakey,
    srv,
    hashedDatakey: hashedDatakey,
    skynetClient: skynetClient,
  );

  return updated;
}

Future<bool> setEntryRaw(
  SkynetUser user,
  String? datakey,
  SignedRegistryEntry srv, {
  String? hashedDatakey,
  required SkynetClient skynetClient,
}) async {
  final uri = Uri.https(skynetClient.portalHost, unencodedPath);

  final data = {
    'publickey': {
      'algorithm': 'ed25519',
      'key': user.publicKey.bytes,
    },
    'datakey': hashedDatakey ?? hex.encode(hashDatakey(datakey!)),
    'revision': srv.entry.revision,
    'data': srv.entry.data,
    'signature': srv.signature!.bytes,
  };

  final res = await skynetClient.httpClient.post(
    uri,
    body: json.encode(data),
    headers: skynetClient.headers,
  );

  if (res.statusCode == 204) {
    return true;
  }
  throw Exception(
      'unexpected response status code ${res.statusCode} ${res.body}');
}

String getEntryLink(
  String userId,
  String datakey, {
  String? hashedDatakey,
  required SkynetClient skynetClient,
}) {
  userId = trimUserIdPrefix(userId);
  Uint8List tweak;
  if (hashedDatakey != null) {
    tweak = Uint8List.fromList(hex.decode(hashedDatakey));
  } else {
    tweak = hashDatakey(datakey);
  }
  final siaPublicKey = newEd25519PublicKey(userId);

  final skylink = newSkylinkV2(siaPublicKey, tweak).toString();
  return skylink;
}

Uint8List getEntryLinkRaw(
  String userId,
  String datakey, {
  String? hashedDatakey,
  /* required SkynetClient skynetClient, */
}) {
  userId = trimUserIdPrefix(userId);
  Uint8List tweak;
  if (hashedDatakey != null) {
    tweak = Uint8List.fromList(hex.decode(hashedDatakey));
  } else {
    tweak = hashDatakey(datakey);
  }
  final siaPublicKey = newEd25519PublicKey(userId);

  return newSkylinkV2(siaPublicKey, tweak).toBytes();
}
