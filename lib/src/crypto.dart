import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:skynet/src/blake2b/blake2b_hash.dart';

import 'encode_endian/base.dart';
import 'encode_endian/encode_endian.dart';
import 'package:cryptography/cryptography.dart' hide MacAlgorithm;

final ed25519 = Ed25519();

String decodeSkylinkFromRegistryEntry(Uint8List data) {
  if (data.length == 46) {
    return utf8.decode(data);
  }
  return base64Url.encode(data).replaceAll('=', '');
}

Uint8List convertSkylinkToUint8List(String skylink) {
  while (skylink.length % 4 != 0) {
    skylink += '=';
  }
  return base64Url.decode(skylink);
}

String deriveChildSeed(String masterSeed, String derivationPath) {
  final list = Uint8List.fromList([
    ...withPadding(masterSeed.length),
    ...utf8.encode(masterSeed),
    ...withPadding(derivationPath.length),
    ...utf8.encode(derivationPath),
  ]);

  return hex.encode(Blake2bHash.hashWithDigestSize(
    256,
    list,
  ));

  // return hashAll(encodeString(masterSeed), encodeString(seed)));
}

List<int> withPadding(int i) {
  return encodeEndian(i, 8, endianType: EndianType.littleEndian) as List<int>;
}

int decodeUint8(List<int> bytes) {
  int result = 0;

  int position = 0;
  for (final int i in bytes) {
    result += i * (pow(2, position) as int);

    position += 8;
  }

  return result;
}

Uint8List hashDatakey(String datakey) {
  final l = utf8.encode(datakey);
  final list = Uint8List.fromList([
    ...withPadding(l.length),
    ...l,
  ]);

  return Blake2bHash.hashWithDigestSize(
    256,
    list,
  );
}

Uint8List hashRawDatakey(Uint8List datakey) {
  final list = Uint8List.fromList([
    ...withPadding(datakey.length),
    ...datakey,
  ]);

  return Blake2bHash.hashWithDigestSize(
    256,
    list,
  );
}

/**
 * Generates a keypair from a given hash.
 *
 * @param hash - The hash.
 * @returns - The keypair.
 */
Future<SimpleKeyPair> genKeyPairFromHash(Uint8List hash) async {
  final hashBytes = hash.sublist(0, 32);

  // const { publicKey, secretKey } = sign.keyPair.fromSeed(hashBytes);

  final ed25519 = Ed25519();

  return await ed25519.newKeyPairFromSeed(hashBytes);
}

/**
 * Hashes the given message with the given salt applied.
 *
 * @param message - The message to hash (e.g. a seed).
 * @param salt - The salt to apply.
 * @returns - The hash.
 */
Uint8List hashWithSalt(Uint8List message, String salt) {
  final s1 = sha512.convert(utf8.encode(salt)).bytes;
  final s2 = sha512.convert(message).bytes;

  final bytes = sha512.convert([...s1, ...s2]).bytes.sublist(0, 32);

  return Uint8List.fromList(bytes);
}
