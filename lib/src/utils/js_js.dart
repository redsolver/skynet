@JS()
library define_property;

import 'package:js/js.dart';

@JS()
@anonymous
class Description {
  external factory Description({bool configurable, bool enumerable, value});
}

@JS('Object.defineProperty')
external void defineProperty(o, String prop, Description description);

void setValue(o, String key, value) => defineProperty(
    o,
    key,
    new Description(
      value: value,
    ));

@JS('JSON.stringify')
external String stringify(Object obj);
