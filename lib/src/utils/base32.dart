library base32;

import 'dart:typed_data';

// ignore: camel_case_types
class base32 {
  /// Takes in a [byteList] converts it to a Uint8List so that I can run
  /// bit operations on it, then outputs a [String] representation of the
  /// base32.
  static String encode(Uint8List bytesList) {
    var i = 0;
    var count = (bytesList.length ~/ 5) * 5;
    var base32str = '';
    while (i < count) {
      var v1 = bytesList[i++];
      var v2 = bytesList[i++];
      var v3 = bytesList[i++];
      var v4 = bytesList[i++];
      var v5 = bytesList[i++];

      base32str += _base32Chars[v1 >> 3] +
          _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          _base32Chars[(v2 >> 1) & 31] +
          _base32Chars[(v2 << 4 | v3 >> 4) & 31] +
          _base32Chars[(v3 << 1 | v4 >> 7) & 31] +
          _base32Chars[(v4 >> 2) & 31] +
          _base32Chars[(v4 << 3 | v5 >> 5) & 31] +
          _base32Chars[v5 & 31];
    }

    var remain = bytesList.length - count;
    if (remain == 1) {
      var v1 = bytesList[i];
      base32str +=
          _base32Chars[v1 >> 3] + _base32Chars[(v1 << 2) & 31] + '======';
    } else if (remain == 2) {
      var v1 = bytesList[i++];
      var v2 = bytesList[i];
      base32str += _base32Chars[v1 >> 3] +
          _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          _base32Chars[(v2 >> 1) & 31] +
          _base32Chars[(v2 << 4) & 31] +
          '====';
    } else if (remain == 3) {
      var v1 = bytesList[i++];
      var v2 = bytesList[i++];
      var v3 = bytesList[i];
      base32str += _base32Chars[v1 >> 3] +
          _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          _base32Chars[(v2 >> 1) & 31] +
          _base32Chars[(v2 << 4 | v3 >> 4) & 31] +
          _base32Chars[(v3 << 1) & 31] +
          '===';
    } else if (remain == 4) {
      var v1 = bytesList[i++];
      var v2 = bytesList[i++];
      var v3 = bytesList[i++];
      var v4 = bytesList[i];
      base32str += _base32Chars[v1 >> 3] +
          _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          _base32Chars[(v2 >> 1) & 31] +
          _base32Chars[(v2 << 4 | v3 >> 4) & 31] +
          _base32Chars[(v3 << 1 | v4 >> 7) & 31] +
          _base32Chars[(v4 >> 2) & 31] +
          _base32Chars[(v4 << 3) & 31] +
          '=';
    }
    return base32str;
  }

  static Uint8List _hexDecode(final String input) => Uint8List.fromList([
        for (int i = 0; i < input.length; i += 2)
          int.parse(input.substring(i, i + 2), radix: 16),
      ]);

  static String _hexEncode(final Uint8List input) => [
        for (int i = 0; i < input.length; i++)
          input[i].toRadixString(16).padLeft(2, '0')
      ].join();

  /// Takes in a [hex] string, converts the string to a byte list
  /// and runs a normal encode() on it. Returning a [String] representation
  /// of the base32.
  static String encodeHexString(String b32hex) {
    return encode(_hexDecode(b32hex));
  }

  /// Takes in a [utf8string], converts the string to a byte list
  /// and runs a normal encode() on it. Returning a [String] representation
  /// of the base32.
  static String encodeString(String utf8string) {
    return encode(Uint8List.fromList(utf8string.codeUnits));
  }

  /// Takes in a [base32] string and decodes it back to a [String] in hex format.
  static String decodeAsHexString(String base32) {
    return _hexEncode(decode(base32));
  }

  /// Takes in a [base32] string and decodes it back to a [String].
  static String decodeAsString(String base32) {
    return decode(base32)
        .toList()
        .map((charCode) => String.fromCharCode(charCode))
        .join();
  }

  /// Takes in a [base32] string and decodes it back to a [Uint8List] that can be
  /// converted to a hex string using hexEncode
  static Uint8List decode(String base32) {
    base32 = base32.toUpperCase();
    if (base32.isEmpty) {
      return Uint8List(0);
    }
    if (!_isValid(base32)) {
      throw FormatException('Invalid Base32 characters');
      //return Uint8List(8);
    }

    var length = base32.indexOf('=');
    if (length == -1) {
      length = base32.length;
    }

    var i = 0;
    var count = length >> 3 << 3;
    var bytes = <int>[];
    while (i < count) {
      var v1 = _base32Decode[base32[i++]] ?? 0;
      var v2 = _base32Decode[base32[i++]] ?? 0;
      var v3 = _base32Decode[base32[i++]] ?? 0;
      var v4 = _base32Decode[base32[i++]] ?? 0;
      var v5 = _base32Decode[base32[i++]] ?? 0;
      var v6 = _base32Decode[base32[i++]] ?? 0;
      var v7 = _base32Decode[base32[i++]] ?? 0;
      var v8 = _base32Decode[base32[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
      bytes.add((v4 << 4 | v5 >> 1) & 255);
      bytes.add((v5 << 7 | v6 << 2 | v7 >> 3) & 255);
      bytes.add((v7 << 5 | v8) & 255);
    }

    var remain = length - count;
    if (remain == 2) {
      var v1 = _base32Decode[base32[i++]] ?? 0;
      var v2 = _base32Decode[base32[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
    } else if (remain == 4) {
      var v1 = _base32Decode[base32[i++]] ?? 0;
      var v2 = _base32Decode[base32[i++]] ?? 0;
      var v3 = _base32Decode[base32[i++]] ?? 0;
      var v4 = _base32Decode[base32[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
    } else if (remain == 5) {
      var v1 = _base32Decode[base32[i++]] ?? 0;
      var v2 = _base32Decode[base32[i++]] ?? 0;
      var v3 = _base32Decode[base32[i++]] ?? 0;
      var v4 = _base32Decode[base32[i++]] ?? 0;
      var v5 = _base32Decode[base32[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
      bytes.add((v4 << 4 | v5 >> 1) & 255);
    } else if (remain == 7) {
      var v1 = _base32Decode[base32[i++]] ?? 0;
      var v2 = _base32Decode[base32[i++]] ?? 0;
      var v3 = _base32Decode[base32[i++]] ?? 0;
      var v4 = _base32Decode[base32[i++]] ?? 0;
      var v5 = _base32Decode[base32[i++]] ?? 0;
      var v6 = _base32Decode[base32[i++]] ?? 0;
      var v7 = _base32Decode[base32[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
      bytes.add((v4 << 4 | v5 >> 1) & 255);
      bytes.add((v5 << 7 | v6 << 2 | v7 >> 3) & 255);
    }
    return Uint8List.fromList(bytes);
  }

  static bool _isValid(String b32str) {
    if (b32str.length % 2 != 0 || !_base32Regex.hasMatch(b32str)) {
      return false;
    }
    return true;
  }

  static final _base32Regex = RegExp(r'^[A-V0-0=]+$');
  static const _base32Chars = '0123456789abcdefghijklmnopqrstuv';
  static const _base32Decode = {
    '0': 0,
    '1': 1,
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    'A': 10,
    'B': 11,
    'C': 12,
    'D': 13,
    'E': 14,
    'F': 15,
    'G': 16,
    'H': 17,
    'I': 18,
    'J': 19,
    'K': 20,
    'L': 21,
    'M': 22,
    'N': 23,
    'O': 24,
    'P': 25,
    'Q': 26,
    'R': 27,
    'S': 28,
    'T': 29,
    'U': 30,
    'V': 31
  };
}
