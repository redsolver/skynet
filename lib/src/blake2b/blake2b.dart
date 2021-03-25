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
library blake2b;

import 'dart:typed_data';

import 'byte_utils.dart';
import 'const.dart';
import 'package:fixnum/fixnum.dart';

/// Blake2b
class Blake2b {
  Blake2b(int digestSize) {
    assert(digestSize == 160 ||
        digestSize == 256 ||
        digestSize == 384 ||
        digestSize == 512);

    this._buffer = Uint8List(Const.blockLengthBytes);
    this._keyLength = 0;
    this._digestSize = digestSize ~/ 8;
    init();
  }

  blake2bWithKey(final Uint8List key) {
    assert(key.length <= 64);
    this._buffer = Uint8List(Const.blockLengthBytes);
    if (null != key) {
      this._key!.addAll(key);
      this._keyLength = key.length;

      this._buffer.addAll(key);
      this._bufferPos = Const.blockLengthBytes; // zero padding
    }
    _digestSize = 64;
    init();
  }

  blake2b(final Uint8List key, final int digestSize, final Uint8List salt,
      final Uint8List personalization) {
    this._buffer = Uint8List(Const.blockLengthBytes);
    assert(1 <= digestSize && digestSize <= 64);
    this._digestSize = digestSize;

    if (null != salt) {
      assert(salt.length == 16);
      this._salt!.addAll(salt);
    }

    if (null != personalization) {
      assert(personalization.length == 16);
      this._personalization!.addAll(personalization);
    }

    if (null != key) {
      this._key!.addAll(key);
      this._keyLength = key.length;

      this._buffer.addAll(key);
      this._bufferPos = Const.blockLengthBytes; // zero padding
    }

    init();
  }

  // General parameters
  int _digestSize = 64; // 1- 64 bytes
  int _keyLength = 0; // 0 - 64 bytes for keyed hashing for MAC
  Uint8List? _salt; // new byte[16];
  Uint8List? _personalization; // new byte[16];

  // The key
  Uint8List? _key;

  // whenever this buffer overflows, it will be processed
  // in the compress() function.
  // For performance issues, Int64 messages will not use this buffer.
  Uint8List _buffer =
      Uint8List(Const.blockLengthBytes); // new byte[BLOCK_LENGTH_BYTES];

  // Position of last inserted byte:
  int _bufferPos = 0; // a value from 0 up to 128

  List<Int64> _internalState = List<Int64>.filled(
      16, Int64.fromInts(0, 0)); // In the Blake2b paper it is called: v

  List<Int64>? _chainValue; // state vector, in the Blake2b paper it is called: h

  Int64 _t0 = Int64.fromInts(
      0, 0); // holds last significant bits, counter (counts bytes)
  Int64 _t1 = Int64.fromInts(0, 0); // counter: Length up to 2^128 are supported
  Int64 _f0 = Int64.fromInts(0, 0); // finalization flag, for last block: ~0L

  void init() {
    if (null == _chainValue) {
      final List<Int64> newChainValue = [];

      // 0
      newChainValue.add(
          Const.blake2bIv[0] ^ (_digestSize | (_keyLength << 8) | 0x1010000));
      // 0x1010000 = ((fanout << 16) | (depth << 24) | (leafLength <<
      // 32));
      // with fanout = 1; depth = 0; leafLength = 0;

      // 1
      newChainValue
          .add(Const.blake2bIv[1]); // ^ nodeOffset; with nodeOffset = 0;

      // 2
      newChainValue
          .add(Const.blake2bIv[2]); // ^ ( nodeDepth | (innerHashLength << 8) );
      // with nodeDepth = 0; innerHashLength = 0;

      // 3
      newChainValue.add(Const.blake2bIv[3]);

      // 4, 5
      newChainValue.add(Const.blake2bIv[4]);
      newChainValue.add(Const.blake2bIv[5]);

      if (null != _salt) {
        newChainValue[4] ^= (ByteUtils.bytes2long(_salt!, 0));
        newChainValue[5] ^= (ByteUtils.bytes2long(_salt!, 8));
      }

      // 6, 7
      newChainValue.add(Const.blake2bIv[6]);
      newChainValue.add(Const.blake2bIv[7]);

      if (null != _personalization) {
        newChainValue[6] ^= (ByteUtils.bytes2long(_personalization!, 0));
        newChainValue[7] ^= (ByteUtils.bytes2long(_personalization!, 8));
      }

      _chainValue = newChainValue;
    }
  }

  void _initializeInternalState() {
    _internalState =
        _arrayCopyI64(_chainValue, 0, _internalState, 0, _chainValue!.length);
    _internalState = _arrayCopyI64(
        Const.blake2bIv, 0, _internalState, _chainValue!.length, 4);

    _internalState[12] = _t0 ^ Const.blake2bIv[4];
    _internalState[13] = _t1 ^ Const.blake2bIv[5];
    _internalState[14] = _f0 ^ Const.blake2bIv[6];
    _internalState[15] = Const.blake2bIv[7];
  }

  void reset() {
    _bufferPos = 0;
    _f0 = Int64.fromInts(0, 0);
    _t0 = Int64.fromInts(0, 0);
    _t1 = Int64.fromInts(0, 0);
    _chainValue = null;

    _buffer.fillRange(0, _buffer.length, 0);

    if (_key != null) {
      _buffer.addAll(_key!);
      _bufferPos = Const.blockLengthBytes; // zero padding
    }
    init();
  }

  void clearKey() {
    if (null != _key) {
      _key!.fillRange(0, _key!.length, 0);
      _buffer.fillRange(0, _buffer.length, 0);
    }
  }

  void clearSalt() {
    if (null != _salt) {
      _salt!.fillRange(0, _salt!.length, 0);
    }
  }

  void update0(final int b) {
    final int remainingLength = Const.blockLengthBytes - _bufferPos;
    if (remainingLength == 0) {
      _t0 += Const.blockLengthBytes;
      if (_t0 == 0) {
        _t1++;
      }
      _compress(_buffer, 0);
      _buffer.fillRange(0, _buffer.length, 0);
      _buffer[0] = b;
      _bufferPos = 1;
    } else {
      _buffer[_bufferPos] = b;
      _bufferPos++;
    }
  }

  void update(Uint8List message, int offset, int len) {
    if (null == message || 0 == len) {
      return;
    }

    int remainingLength = 0;

    if (0 != _bufferPos) {
      // commenced, incomplete buffer

      // complete the buffer:
      remainingLength = Const.blockLengthBytes - _bufferPos;
      if (remainingLength < len) {
        // full buffer + at least 1 byte
        _buffer =
            _arrayCopy(message, offset, _buffer, _bufferPos, remainingLength);
        _t0 += Const.blockLengthBytes;
        if (_t0 == 0) {
          // if message > 2^64
          _t1++;
        }
        _compress(_buffer, 0);
        _bufferPos = 0;
        _buffer.fillRange(0, _buffer.length, 0);
      } else {
        _buffer = _arrayCopy(message, offset, _buffer, _bufferPos, len);
        _bufferPos += len;
        return;
      }
    }

    // process blocks except last block (also if last block is full)
    int messagePos;
    final int blockWiseLastPos = offset + len - Const.blockLengthBytes;

    // block wise 128 bytes
    for (messagePos = offset + remainingLength;
        messagePos < blockWiseLastPos;
        messagePos += Const.blockLengthBytes) {
      // without buffer:
      _t0 += Const.blockLengthBytes;

      if (_t0 == 0) {
        _t1++;
      }

      _compress(message, messagePos);
    }

    // fill the buffer with left bytes, this might be a full block
    _buffer =
        _arrayCopy(message, messagePos, _buffer, 0, offset + len - messagePos);

    _bufferPos += (offset + len) - messagePos;
  }

  Uint8List digest(Uint8List out, final int outOffset) {
    _f0 = Const.f0;
    _t0 += _bufferPos;

    if (0 < _bufferPos && _t0 == 0) {
      _t1++;
    }

    _compress(_buffer, 0);

    _buffer.fillRange(0, _buffer.length, 0);
    _internalState =
        List<Int64>.filled(_internalState.length, Int64.fromInts(0, 0));

    for (int i = 0; i < _chainValue!.length && (i * 8 < _digestSize); i++) {
      Uint8List bytes = ByteUtils.long2bytes(_chainValue![i]);

      if ((i * 8) < (_digestSize - 8)) {
        out = _arrayCopy(bytes, 0, out, outOffset + (i * 8), 8);
      } else {
        out = _arrayCopy(
            bytes, 0, out, outOffset + (i * 8), _digestSize - (i * 8));
      }
    }

    _chainValue = List<Int64>.filled(_chainValue!.length, Int64.fromInts(0, 0));

    reset();

    return out;
  }

  void _compress(Uint8List message, int messagePos) {
    _initializeInternalState();

    List<Int64> m = List<Int64>.filled(16, Int64.fromInts(0, 0));

    for (int j = 0; j < 16; j++) {
      m[j] = ByteUtils.bytes2long(message, messagePos + j * 8);
    }

    for (int round = 0; round < Const.rounds; round++) {
      _g(m[Const.blake2Sigma[round][0]], m[Const.blake2Sigma[round][1]], 0, 4,
          8, 12);
      _g(m[Const.blake2Sigma[round][2]], m[Const.blake2Sigma[round][3]], 1, 5,
          9, 13);
      _g(m[Const.blake2Sigma[round][4]], m[Const.blake2Sigma[round][5]], 2, 6,
          10, 14);
      _g(m[Const.blake2Sigma[round][6]], m[Const.blake2Sigma[round][7]], 3, 7,
          11, 15);
      _g(m[Const.blake2Sigma[round][8]], m[Const.blake2Sigma[round][9]], 0, 5,
          10, 15);
      _g(m[Const.blake2Sigma[round][10]], m[Const.blake2Sigma[round][11]], 1, 6,
          11, 12);
      _g(m[Const.blake2Sigma[round][12]], m[Const.blake2Sigma[round][13]], 2, 7,
          8, 13);
      _g(m[Const.blake2Sigma[round][14]], m[Const.blake2Sigma[round][15]], 3, 4,
          9, 14);
    }

    for (int offset = 0; offset < _chainValue!.length; offset++) {
      _chainValue![offset] = _chainValue![offset] ^
          _internalState[offset] ^
          _internalState[offset + 8];
    }
  }

  void _g(Int64 m1, Int64 m2, int posA, int posB, int posC, int posD) {
    _internalState[posA] = _internalState[posA] + _internalState[posB] + m1;
    _internalState[posD] =
        ByteUtils.rotr64(_internalState[posD] ^ _internalState[posA], 32);

    _internalState[posC] = _internalState[posC] + _internalState[posD];
    _internalState[posB] = ByteUtils.rotr64(
        _internalState[posB] ^ _internalState[posC],
        24); // replaces 25 of BLAKE

    _internalState[posA] = _internalState[posA] + _internalState[posB] + m2;
    _internalState[posD] =
        ByteUtils.rotr64(_internalState[posD] ^ _internalState[posA], 16);

    _internalState[posC] = _internalState[posC] + _internalState[posD];
    _internalState[posB] =
        ByteUtils.rotr64(_internalState[posB] ^ _internalState[posC], 63);
  }

  Uint8List _arrayCopy(
      Uint8List src, int srcOffset, Uint8List dst, int dstOffset, int length) {
    for (var i = 0; i < length; i++) {
      dst[dstOffset + i] = src[srcOffset + i];
    }
    return dst;
  }

  List<Int64> _arrayCopyI64(List<Int64>? src, int srcOffset, List<Int64> dst,
      int dstOffset, int length) {
    for (var i = 0; i < length; i++) {
      dst[dstOffset + i] = src![srcOffset + i];
    }
    return dst;
  }
}
