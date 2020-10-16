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

import 'blake2b.dart';
import 'package:hex/hex.dart';

class Blake2bHash {
  static final int _size = 32;

  static final int _digestSize = _size * 8;

  // hash from hex string to bytes
  static Uint8List hashHexString(String hex) {
    if (null == hex) {
      return null;
    }
    var bytes = HEX.decode(hex);
    return hash(bytes, 0, bytes.length);
  }

  // hash from hex string to hex string
  static String hashHexString2HexString(String hex) {
    return HEX.encode(hashHexString(hex));
  }

  // hash from utf8 string to bytes
  static Uint8List hashUtf8String(String string) {
    Uint8List bytes = Uint8List(string.length);
    for (int i = 0; i < string.length; i++) {
      bytes[i] = string.codeUnitAt(i);
    }
    return hash(bytes, 0, bytes.length);
  }

  // hash from utf8 string to hex string
  static String hashUtf8String2HexString(String string) {
    return HEX.encode(hashUtf8String(string));
  }

  static Uint8List hashWithDigestSize(int digestSize, Uint8List message) {
    Uint8List bytes = Uint8List(digestSize ~/ 8);

    var b = Blake2b(digestSize);
    b.update(message, 0, message.length);

    return b.digest(bytes, 0);
  }

  static Uint8List hash(Uint8List message, int offset, int len) {
    Uint8List bytes = Uint8List(_size);
    var b = Blake2b(_digestSize);
    b.update(message, offset, len);
    return b.digest(bytes, 0);
  }
}
