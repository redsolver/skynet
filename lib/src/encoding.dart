import 'dart:typed_data';

import 'package:skynet/src/mysky/tweak.dart';

/**
 * Encodes the uint8array, prefixed by its length.
 *
 * @param bytes - The input array.
 * @returns - The encoded byte array.
 */
Uint8List encodePrefixedBytes(Uint8List bytes) {
  final len = bytes.length;
  final uint8Bytes = Uint8List(8 + len);
  // const view = new DataView(buf);

  uint8Bytes[0] = len;

  // Sia uses setUint64 which is unavailable in JS.
  // view.setUint32(0, len, true);
  // final uint8Bytes = new Uint8Array(buf);
  // uint8Bytes.set(bytes, 8);
  copy(uint8Bytes, 8, bytes);

  return uint8Bytes;
}
