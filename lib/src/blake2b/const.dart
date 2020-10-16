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
import 'package:fixnum/fixnum.dart';

class Const {
  static final Int64 f0 = Int64.fromInts(0xffffffff, 0xffffffff);

  // Blake2b Initialization Vector:
  // Produced from the square root of primes 2, 3, 5, 7, 11, 13, 17, 19.
  // The same as SHA-512 IV.
  static final List<Int64> blake2bIv = [
    Int64.fromInts(0x6a09e667, 0xf3bcc908),
    Int64.fromInts(0xbb67ae85, 0x84caa73b),
    Int64.fromInts(0x3c6ef372, 0xfe94f82b),
    Int64.fromInts(0xa54ff53a, 0x5f1d36f1),
    Int64.fromInts(0x510e527f, 0xade682d1),
    Int64.fromInts(0x9b05688c, 0x2b3e6c1f),
    Int64.fromInts(0x1f83d9ab, 0xfb41bd6b),
    Int64.fromInts(0x5be0cd19, 0x137e2179),
  ];

  // Message word permutations:
  static final List<List<int>> blake2Sigma = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
    [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
    [11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4],
    [7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
    [9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13],
    [2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9],
    [12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11],
    [13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10],
    [6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5],
    [10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
    [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3]
  ];

  static final int blockLengthBytes = 128; // bytes

  static final int rounds = 12; // to use for Catenas H'
}
