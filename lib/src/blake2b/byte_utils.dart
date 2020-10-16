///
/// Copyright (c) [2019] [riclava]
/// [blake2b] is licensed under the Mulan PSL v1.
/// You can use this software according to the terms and conditions of the Mulan PSL v1.
/// You may obtain a copy of Mulan PSL v1 at:
///     http://license.coscl.org.cn/MulanPSL
/// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
/// PURPOSE.
/// See the Mulan PSL v1 for more details.
///
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';

class ByteUtils {
  static Int64 bytes2long(final Uint8List byteArray, final int offset) {
    // & 0xFF is useless
    return ((Int64.fromInts(0, byteArray[offset] & 0xFF)) |
        (Int64.fromInts(0, byteArray[offset + 1] & 0xFF) << 8) |
        (Int64.fromInts(0, byteArray[offset + 2] & 0xFF) << 16) |
        (Int64.fromInts(0, byteArray[offset + 3] & 0xFF) << 24) |
        (Int64.fromInts(0, byteArray[offset + 4] & 0xFF) << 32) |
        (Int64.fromInts(0, byteArray[offset + 5] & 0xFF) << 40) |
        (Int64.fromInts(0, byteArray[offset + 6] & 0xFF) << 48) |
        (Int64.fromInts(0, byteArray[offset + 7] & 0xFF) << 56));
  }

  static Uint8List long2bytes(final Int64 longValue) {
    return Uint8List.fromList(longValue.toBytes());
  }

  static Int64 rotr64(final Int64 x, final int rot) {
    return x.shiftRightUnsigned(rot) | x << (64 - rot);
  }
}
