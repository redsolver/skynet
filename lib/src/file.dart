

import 'dart:convert';
import 'dart:typed_data';

class SkyFile {
  final String? filename;
  final String? type;
  final Uint8List content;

  String? strContent;

  String? get asString {
    strContent ??= utf8.decode(content);
    return strContent;
  }

  SkyFile({required this.content, this.filename, this.type});
}
