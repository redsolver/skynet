import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'blake2b/blake2b_hash.dart';
import 'crypto.dart';
import 'package:cryptography/cryptography.dart' hide MacAlgorithm;

class RegistryEntry {
  //' Uint8List tweak;
  String? datakey;
  Uint8List? hashedDatakey;

  late Uint8List data;
  late int revision;

  RegistryEntry(
      {/* this.tweak, */ this.datakey,
      this.hashedDatakey,
      required this.data,
      required this.revision});

  Uint8List toBytes() => Uint8List.fromList([
        ...withPadding(revision),
        ...data,
      ]);

  RegistryEntry.fromBytes(List<int> bytes) {
    revision = decodeUint8(bytes.sublist(0, 8));
    data = Uint8List.fromList(bytes.sublist(8));
  }

  Uint8List hash() {
    if (datakey != null) hashedDatakey = hashDatakey(datakey!);

    final list = Uint8List.fromList([
      ...hashedDatakey!,
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

class SignedRegistryEntry {
  late RegistryEntry entry;
  Signature? signature;

  void setPublicKey(List<int> publicKey) {
    signature = Signature(signature!.bytes,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519));
  }

  Uint8List toBytes() =>
      Uint8List.fromList([...signature!.bytes, ...entry.toBytes()]);

  SignedRegistryEntry.fromBytes(List<int> bytes,
      {required List<int> publicKeyBytes}) {
    signature = Signature(bytes.sublist(0, 64),
        publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519));

    entry = RegistryEntry.fromBytes(bytes.sublist(64));
  }

  Map toJson() => {
        'datakey':
            hex.encode(entry.hashedDatakey ?? hashDatakey(entry.datakey!)),
        'data': hex.encode(entry.data),
        'revision': entry.revision,
        'signature': hex.encode(signature!.bytes),
      };
/* 
  SignedRegistryEntry.fromJson(Map m) {
    // TODO!
    signature = Signature(
      hex.decode(m['signature']),
    );
    entry = RegistryEntry(
      /* tweak: hex.decode(m['tweak']), */
      data: hex.decode(m['data']),
      revision: m['revision'],
    );

    if (m['datakey'] != null) entry.datakey = m['datakey'];
  }
 */
  SignedRegistryEntry({required this.entry, this.signature});
}
