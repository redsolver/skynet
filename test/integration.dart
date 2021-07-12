import 'dart:io';

import 'dart:typed_data';
import 'package:skynet/skynet.dart';
import 'package:skynet/src/mysky/encrypted_files.dart';
import 'package:test/test.dart';

void main() {
  final portal = 'siasky.net';
  final client = SkynetClient(portal: 'siasky.net');
  /* 
  group('Integration test for portal ${portal}', ()  {
  group("File API integration tests", ()  {
    final userID = "89e5147864297b80f5ddf29711ba8c093e724213b0dcbefbc3860cc6d598cc35";
    final path = "snew.hns/asdf";
    test("Should get existing File API JSON data",  () async {
      const expected = { name: "testnames" };
      const { data: received } = await client.file.getJSON(userID, path);
      expect(received).toEqual(expect.objectContaining(expected));
    });
    test("Should get existing File API entry data", async () => {
      const expected = new Uint8Array([
        65, 65, 67, 116, 77, 77, 114, 101, 122, 76, 56, 82, 71, 102, 105, 98, 104, 67, 53, 79, 98, 120, 48, 83, 102, 69,
        106, 48, 77, 87, 108, 106, 95, 112, 55, 97, 95, 77, 107, 90, 85, 81, 45, 77, 57, 65,
      ]);
      const { data: received } = await client.file.getEntryData(userID, path);
      expect(received).toEqualUint8Array(expected);
    });
    it("getEntryData should return null for non-existent File API entry data", async () => {
      const { publicKey: userID } = genKeyPairAndSeed();
      const { data: received } = await client.file.getEntryData(userID, path);
      expect(received).toBeNull();
    });

    it("Should get an existing entry link for a user ID and path", async () => {
      const expected = `${uriSkynetPrefix}AQAKDRJbfAOOp3Vk8L-cjuY2d34E8OrEOy_PTsD0xCkYOQ`;

      const entryLink = await client.file.getEntryLink(userID, path);
      expect(entryLink).toEqual(expected);
    });
  }); */

  group("Encrypted File API integration tests", () {
    final userID =
        "4dfb9ce035e4e44711c1bb0a0901ce3adc2a928b122ee7b45df6ac47548646b0";
    // Path seed for "test.hns/encrypted".
    final pathSeed =
        "fe2c5148646532a442dd117efab3ff2a190336da506e363f80fb949513dab811";

    test("Should get existing encrypted JSON", () async {
      final expectedJson = {'message': "foo"};

      final res = await client.file.getJSONEncrypted(
        userID,
        pathSeed,
      );

      expect(
        res.data,
        equals(
          expectedJson,
        ),
      );
    });

    test("Should return null for inexistant encrypted JSON", () async {
      final userID =
          "4dfb9ce035e4e44711c1bb0a0901ce3adc2a928b122ee7b45df6ac47548646b0";
      final pathSeed = List.generate(64, (index) => 'a').join();

      // String? error;
      // try {
      final res = await client.file.getJSONEncrypted(
        userID,
        pathSeed,
      );
      /*  } catch (e) {
        print('ERROR $e');
        error = e.toString();
      } */
      expect(res.data, equals(null));
    });
  });
}
