import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:skynet/src/mysky/encrypted_files.dart';
import 'package:test/test.dart';

/* import { readFileSync } from "fs";

import {
  decryptJSONFile,
  deriveEncryptedFileKeyEntropy,
  deriveEncryptedFileSeed,
  deriveEncryptedFileTweak,
  encodeEncryptedFileMetadata,
  ENCRYPTED_JSON_RESPONSE_VERSION,
  ENCRYPTION_KEY_LENGTH,
  encryptJSONFile,
  padFileSize,
} from "./encrypted_files"; */

void main() {
/* expect.extend({
  // source https://stackoverflow.com/a/60818105/6085242
  toEqualUint8Array(received: Uint8Array, argument: Uint8Array) {
    if (received.length !== argument.length) {
      return { pass: false, message: () => `expected ${received} to equal ${argument}` };
    }
    for (let i = 0; i < received.length; i++) {
      if (received[i] !== argument[i]) {
        return { pass: false, message: () => `expected ${received} to equal ${argument}` };
      }
    }
    return { pass: true, message: () => `expected ${received} not to equal ${argument}` };
  },
}); */

  group("deriveEncryptedFileKeyEntropy", () {
    test("Should derive the correct encrypted file key entropy", () {
      // Hard-code expected value to catch breaking changes.
      final pathSeed = List.generate(64, (index) => 'a').join();

      final expectedEntropy = [
        145,
        247,
        132,
        82,
        184,
        94,
        1,
        97,
        214,
        174,
        84,
        50,
        40,
        0,
        247,
        144,
        106,
        110,
        227,
        25,
        193,
        138,
        249,
        233,
        32,
        94,
        186,
        244,
        48,
        171,
        115,
        171,
      ];

      final result = deriveEncryptedFileKeyEntropy(pathSeed);

      expect(result, equals(Uint8List.fromList(expectedEntropy)));
    });
  });

  group("deriveEncryptedFileSeed", () {
    test("Should derive the correct encrypted file seed", () {
      // Hard-code expected value to catch breaking changes.

      final pathSeed = List.generate(64, (index) => 'a').join();

      const subPath = "path/to/file.json";

      // Derive seed for a file.
      final fileSeed = deriveEncryptedFileSeed(pathSeed, subPath, false);

      expect(
          fileSeed,
          equals(
              'ace80613629a4049386b3007c17aa9aa2a7f86a7649326c03d56eb40df23593b'));

      // Derive seed for a directory.
      final directorySeed = deriveEncryptedFileSeed(pathSeed, subPath, true);

      expect(
          directorySeed,
          equals(
              'fa91607af922c9e57d794b7980e550fb15db99e62960fb0908b0f5af10afaf16'));

/* TODO    expect(
     fileSeed,
       notEquals(
              directorySeed)); */
    });
  });

  group("deriveEncryptedFileTweak", () {
    test("Should derive the correct encrypted file tweak", () {
      // Hard-code expected value to catch breaking changes.
      final seed = "test.hns/foo";
      final expectedTweak =
          "352140f347807438f8f74edf3e0750a408f39b9f2ae4147eb9055d396b467fc8";

      final result = deriveEncryptedFileTweak(seed);

      expect(result, equals(expectedTweak));
    });
  });

  const encryptedTestFilePath = "test_data/encrypted-json-file";
  const jsonData = {'message': "text"};
  const v = ENCRYPTED_JSON_RESPONSE_VERSION;
  const fullData = {'_data': jsonData, '_v': v};
  final key = Uint8List(ENCRYPTION_KEY_LENGTH);
  final fileData = File(encryptedTestFilePath).readAsBytesSync();

  group("decryptJSONFile", () {
    test("Should decrypt the given test data", () {
      expect(fileData.length, equals(4096));

      final result = decryptJSONFile(fileData, key);

      expect(result, equals(fullData));
    });

    test("Should fail to decrypt bad data", () {
      String? error;
      try {
        decryptJSONFile(Uint8List(4096), key);
      } catch (e) {
        error = e.toString();
      }
      expect(
          error,
          equals(
            "Received unrecognized JSON response version '0' in metadata, expected '1'",
          ));
    });

    test("Should fail to decrypt data with a corrupted nonce", () {
      final data = File(encryptedTestFilePath).readAsBytesSync();
      data[0]++;

      String? error;
      try {
        decryptJSONFile(data, key);
      } catch (e) {
        error = e.toString();
      }
      expect(
          error,
          equals(
              'The message is forged or malformed or the shared secret is invalid'));
    });

    test("Should fail to decrypt data with a corrupted metadata", () {
      final data = File(encryptedTestFilePath).readAsBytesSync();
      data[ENCRYPTION_NONCE_LENGTH]++;

      String? error;
      try {
        decryptJSONFile(data, key);
      } catch (e) {
        error = e.toString();
      }
      expect(
          error,
          equals(
            "Received unrecognized JSON response version '2' in metadata, expected '1'",
          ));
    });

    test("Should fail to decrypt data with corrupted encrypted bytes", () {
      final data = File(encryptedTestFilePath).readAsBytesSync();
      data[ENCRYPTION_NONCE_LENGTH + ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH]++;

      String? error;
      try {
        decryptJSONFile(data, key);
      } catch (e) {
        error = e.toString();
      }
      expect(
          error,
          equals(
              'The message is forged or malformed or the shared secret is invalid'));
    });

    test("Should fail to decrypt data that was not padded correctly", () {
      var data = File(encryptedTestFilePath).readAsBytesSync();
      data = data.sublist(0, data.length - 1);

      expect(data.length, equals(4095));

      String? error;
      try {
        decryptJSONFile(data, key);
      } catch (e) {
        error = e.toString();
      }
      expect(
          error,
          equals(
            "Expected parameter 'data' to be padded encrypted data, length was '4095', nearest padded block is '4096'",
          ));
    });
  });

  test("encryptJSONFile", () {
    final result = encryptJSONFile(fullData, key);
    File('test_data/encrypted-json-file2').writeAsBytesSync(result);
    expect(result.length, equals(4096));
  });

  group("encodeEncryptedFileMetadata", () {
    test("Should fail to encode metadata with an invalid version", () {
      const version = 256;
      final metadata = EncryptedFileMetadata(version: version);

      String? error;
      try {
        encodeEncryptedFileMetadata(metadata);
      } catch (e) {
        error = e.toString();
      }
      expect(
          error,
          equals(
              "Metadata version '${version}' could not be stored in a uint8"));
    });
  });
  const kib = 1 << 10;
  const mib = 1 << 20;
  const gib = 1 << 30;
  group("padFileSize", () {
    const sizes = [
      [1 * kib, 4 * kib],
      [4 * kib, 4 * kib],
      [5 * kib, 8 * kib],
      [105 * kib, 112 * kib],
      [305 * kib, 320 * kib],
      [351 * kib, 352 * kib],
      [352 * kib, 352 * kib],
      [mib, mib],
      [100 * mib, 104 * mib],
      [gib, gib],
      [100 * gib, 104 * gib],
    ];

    for (final size in sizes) {
      final initialSize = size[0];
      final expectedSize = size[1];
      test('Should pad the file size $initialSize to $expectedSize', () {
        final size = padFileSize(initialSize);
        expect(size, equals(expectedSize));
      });
    }

    /*    test("Should throw on a really big number.", () {
      String? error;
      try {
        print(padFileSize((pow(2, 53) - 1).round()));
      } catch (e) {
        error = e.toString();
      }
      expect(error, equals("Could not pad file size, overflow detected."));
    }); */
  });
}
