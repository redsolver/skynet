import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:pinenacl/api.dart';
import 'package:skynet/skynet.dart';
import 'package:skynet/src/crypto.dart';
import 'package:skynet/src/registry_classes.dart';
import 'package:test/test.dart';

void main() async {
  test('resolveSkylink', () {
    final skynetClient = SkynetClient('siasky.net');

    expect(
      skynetClient.resolveSkylink(
          'sia://LACYG8_AGc5UexNDGc86fjF-KkW9YncLRBkeu5nCeD1ltA'),
      equals(
        'https://siasky.net/LACYG8_AGc5UexNDGc86fjF-KkW9YncLRBkeu5nCeD1ltA',
      ),
    );

    expect(
      skynetClient.resolveSkylink(
          'sia://skysend.hns'),
      equals(
        'https://skysend.hns.siasky.net',
      ),
    );

    expect(
      skynetClient.resolveSkylink(
          'sia://skychess.hns/#/watch/4ba2676c7839990978b5ac8ee3a903e4702bea5cf17924e0b5f71d6f9a6d26ed'),
      equals(
        'https://skychess.hns.siasky.net/#/watch/4ba2676c7839990978b5ac8ee3a903e4702bea5cf17924e0b5f71d6f9a6d26ed',
      ),
    );
  });

  group('SkyDB', () {
    test('HashRegistryValue', () {
      final re = RegistryEntry(
        datakey: 'HelloWorld',
        data: Uint8List.fromList(utf8.encode('abc')),
        revision: 123456789,
      );
      final hash = hex.encode(re.hash());

      expect(
          hash,
          equals(
              '788dddf5232807611557a3dc0fa5f34012c2650526ba91d55411a2b04ba56164'));
    });
  });

  test('deriveChildSeed', () {
    final childSeed = deriveChildSeed(
        '788dddf5232807611557a3dc0fa5f34012c2650526ba91d55411a2b04ba56164',
        'skyfeed');

    expect(
        childSeed,
        equals(
            '6694f6cfd45be4d920d9c9643ab0f97da36e8d0576054121cba8612eec92fdc6'));
  });

  final skynetUser = SkynetUser.fromSeedAsync(List.generate(32, (index) => 0));
  await skynetUser.init();
  group('SkynetUser', () {
    test('init', () async {
      // ! ed25519
      expect(
          hex.encode((await skynetUser.keyPair.extractPublicKey()).bytes),
          equals(
              '3b6a27bcceb6a42d62a3a8d02a6f0d73653215771de243a63ac048a18b59da29'));
      expect(
          hex.encode(skynetUser.publicKey.bytes),
          equals(
              '3b6a27bcceb6a42d62a3a8d02a6f0d73653215771de243a63ac048a18b59da29'));

      expect(
          hex.encode(await skynetUser.keyPair.extractPrivateKeyBytes()),
          equals(
              '0000000000000000000000000000000000000000000000000000000000000000'));

      expect(
          skynetUser.id,
          equals(
              '3b6a27bcceb6a42d62a3a8d02a6f0d73653215771de243a63ac048a18b59da29'));

      // ! Encryption

      expect(skynetUser.sk, equals(List.generate(32, (index) => 0)));

      expect(
          hex.encode(skynetUser.pk!.toList()),
          equals(
              '2fe57da347cd62431528daac5fbb290730fff684afc4cfc2ed90995f58cb3b74'));
    });

    test('signature', () async {
      expect(hex.encode((await skynetUser.sign([1, 2, 3, 4, 5, 6])).bytes),
          '95341a59c48c98f4efe57be5e6b57041d856752c4b6e233377c7c69ca0cd042ccf35d2ccddc2eb09db32681ac6f45e5ed570fbe09266d27c299bc56991ca1906');
    });
  });
}
