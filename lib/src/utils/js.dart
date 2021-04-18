import 'dart:convert';

import 'js_js.dart';

dynamic dartify(dynamic arg) {
  final jsonStr = stringify(arg);
  return json.decode(jsonStr);
}

dynamic jsify(dynamic arg) {
  return parse(json.encode(arg));
}
