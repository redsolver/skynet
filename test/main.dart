import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:skynet/skynet.dart';
import 'package:test/test.dart';

void main() {
  group('SkyDB', () {
    test('HashRegistryValue', () {
      final re = RegistryEntry(
        datakey: 'HelloWorld',
        data: utf8.encode('abc'),
        revision: 123456789,
      );
      final hash = hex.encode(re.hash());

      expect(
          hash,
          equals(
              '788dddf5232807611557a3dc0fa5f34012c2650526ba91d55411a2b04ba56164'));
    });
  });
}
