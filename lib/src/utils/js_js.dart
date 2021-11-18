@JS()
library define_property;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
@anonymous
class Description {
  external factory Description({bool configurable, bool enumerable, value});
}

@JS('Object.defineProperty')
external void defineProperty(o, String prop, Description description);

@JS('BigInt')
external dynamic JSBigInt(dynamic i);

@JS('document.getElementsByName')
external dynamic getElementsByName(String name);

@JS('eval')
external dynamic eval(String js);

@JS()
@anonymous
class JSRegistryEntry {
  // external bool get responsive;

  // Must have an unnamed factory constructor with named arguments.
  external factory JSRegistryEntry({
    String dataKey,
    Uint8List data,
    dynamic revision,
  });
}

void setValue(o, String key, value) => defineProperty(
    o,
    key,
    new Description(
      value: value,
    ));

@JS('JSON.stringify')
external String stringify(Object obj);

@JS('JSON.parse')
external Object parse(String str);
