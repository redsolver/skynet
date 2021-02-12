import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:skynet/src/blake2b/blake2b_hash.dart';
import 'package:skynet/src/skydb.dart';

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
