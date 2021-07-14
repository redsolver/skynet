import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:skynet/src/blake2b/blake2b_hash.dart';

import 'encode_endian/base.dart';
import 'encode_endian/encode_endian.dart';

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
