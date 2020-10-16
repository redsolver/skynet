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

class Utils {
  static Uint8List int8list2uint8list(Int8List l) {
    Uint8List r = Uint8List(l.length);
    for (int i = 0; i < l.length; i++) {
      r[i] = l[i] & 0xFF;
    }
    return r;
  }
}