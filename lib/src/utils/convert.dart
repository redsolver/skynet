import 'dart:typed_data';
import 'base32.dart';

String encodeSkylinkToBase32(Uint8List skylink) {
  var b32skylink = base32.encode(
    skylink,
  );
  while (b32skylink.endsWith('=')) {
    b32skylink = b32skylink.substring(0, b32skylink.length - 1);
  }
  return b32skylink;
}
