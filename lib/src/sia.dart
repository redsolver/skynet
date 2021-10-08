import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:skynet/src/blake2b/blake2b_hash.dart';
import 'package:skynet/src/encoding.dart';

/**
 * The raw size in bytes of the data that gets put into a link.
 */
const RAW_SKYLINK_SIZE = 34;

/**
 * Creates a new sia public key. Matches Ed25519PublicKey in sia.
 *
 * @param publicKey - The hex-encoded public key.
 * @returns - The SiaPublicKey.
 */
SiaPublicKey newEd25519PublicKey(String publicKey) {
  final algorithm = newSpecifier("ed25519");

  final publicKeyBytes = Uint8List.fromList(hex.decode(publicKey));
  /* validateUint8ArrayLen(
      "publicKeyBytes", publicKeyBytes, "converted publicKey", PUBLIC_KEY_SIZE); */

  return SiaPublicKey(algorithm, publicKeyBytes);
}

/**
 * Creates a new v2 skylink. Matches NewSkylinkV2 in skyd.
 *
 * @param siaPublicKey - The public key as a SiaPublicKey.
 * @param tweak - The hashed tweak.
 * @returns - The v2 skylink.
 */

SiaSkylink newSkylinkV2(SiaPublicKey siaPublicKey, Uint8List tweak) {
  final version = 2;
  final bitfield = version - 1;
  final merkleRoot = deriveRegistryEntryID(siaPublicKey, tweak);
  return new SiaSkylink(bitfield, merkleRoot);
}

class SiaSkylink {
  final int bitfield;
  final Uint8List merkleRoot;
  SiaSkylink(this.bitfield, this.merkleRoot);

  Uint8List toBytes() {
    /* final buf = new ArrayBuffer(RAW_SKYLINK_SIZE);
    const view = new DataView(buf); */

    // view.setUint16(0, this.bitfield, true);

    final uint8Bytes = Uint8List(RAW_SKYLINK_SIZE);

    uint8Bytes[0] = bitfield % 256;
    uint8Bytes[1] = ((bitfield - uint8Bytes[0]) / 256).round();

    copy(uint8Bytes, 2, merkleRoot);

    return uint8Bytes;
  }

  String toString() {
    return base64Url.encode(toBytes()).replaceAll('=', '');
  }
}

void copy(Uint8List list, int index, Uint8List copy) {
  for (final part in copy) {
    list[index] = part;
    index++;
  }
}

const SPECIFIER_LEN = 16;

/**
 * Returns a specifier for given name, a specifier can only be 16 bytes so we
 * panic if the given name is too long.
 *
 * @param name - The name.
 * @returns - The specifier, if valid.
 */
Uint8List newSpecifier(String name) {
  final specifier = Uint8List(SPECIFIER_LEN);
  copy(specifier, 0, Uint8List.fromList(utf8.encode(name)));
  return specifier;
}

const PUBLIC_KEY_SIZE = 32;

class SiaPublicKey {
  final Uint8List algorithm;
  final Uint8List key;
  SiaPublicKey(this.algorithm, this.key);

  Uint8List marshalSia() {
    final bytes = Uint8List(SPECIFIER_LEN + 8 + PUBLIC_KEY_SIZE);
    copy(bytes, 0, algorithm);
    copy(bytes, SPECIFIER_LEN, encodePrefixedBytes(this.key));

    return bytes;
  }
}

/**
 * A helper to derive an entry id for a registry key value pair. Matches `DeriveRegistryEntryID` in sia.
 *
 * @param pubKey - The sia public key.
 * @param tweak - The tweak.
 * @returns - The entry ID as a hash of the inputs.
 */
Uint8List deriveRegistryEntryID(SiaPublicKey pubKey, Uint8List tweak) {
  final list = Uint8List.fromList(pubKey.marshalSia() + tweak);

  return Blake2bHash.hashWithDigestSize(
    256,
    list,
  );
}
