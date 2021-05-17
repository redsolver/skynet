import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:password_hash/password_hash.dart';

import 'package:pinenacl/api.dart' as pinenacl;
import 'package:pinenacl/ed25519.dart' as pinenacl;
import 'package:pinenacl/src/authenticated_encryption/secret.dart' as pinenacl;
import 'package:pinenacl/src/authenticated_encryption/public.dart' as pinenacl;

// User represents a user entity and can be used to sign.
class SkynetUser {
  final ed25519 = Ed25519();

  late String id;

  late SimpleKeyPair keyPair;

  late SimplePublicKey publicKey;
  Future<List<int>> get privateKeySync => keyPair.extractPrivateKeyBytes();

  late List<int> seed;

  late pinenacl.PrivateKey sk;
  pinenacl.PublicKey? pk;

  SkynetUser.fromId(String userId) {
    if (userId.startsWith('ed25519-')) {
      userId = userId.substring(8);
    }
    id = userId;
    publicKey = SimplePublicKey(hex.decode(userId), type: KeyPairType.ed25519);
  }

  static Future<SkynetUser> createFromSeedAsync(List<int> usedSeed) async {
    final user = SkynetUser.fromSeedAsync(usedSeed);
    await user.init();
    return user;
  }

  SkynetUser.fromSeedAsync(List<int> usedSeed) {
    seed = usedSeed;

    sk = pinenacl.PrivateKey(seed);

    pk = sk.publicKey;
  }
  Future<void> init() async {
    keyPair = await ed25519.newKeyPairFromSeed(seed);

    publicKey = await keyPair.extractPublicKey();
    id = hex.encode(publicKey.bytes);
  }

  // see https://github.com/NebulousLabs/skynet-js/blob/f500b5cf879916b3ae26651d714d373414f82497/src/crypto.ts#L75
  static Future<Uint8List> skyIdSeedToEd25519Seed(
      String seedStringInBase64) async {
    // TODO Test this
    /*     String seedStringInBase64) async {
    final hasher = DartPbkdf2(
        macAlgorithm: DartChacha20Poly1305AeadMacAlgorithm(),
        iterations: 1000,
        bits: 256);

    final res = await hasher.deriveKey(
      secretKey: SecretKey(sha256.convert(seedStringInBase64.codeUnits).bytes),
      nonce: pinenacl.PineNaClUtils.randombytes(12),
    );

    return pinenacl.Uint8List.fromList(await res.extractBytes()); */

    final generator =
        PBKDF2(/* hashAlgorithm: Sha256._() */ /* hashAlgorithm: sha1 */);

    return pinenacl.Uint8List.fromList(
        generator.generateKey(seedStringInBase64, '', 1000, 32));
  }

  Future<Signature> sign(List<int> message) {
    return ed25519.sign(message, keyPair: keyPair);
  }

  List<int> symEncrypt(List<int> key, List<int> message) {
    final box = pinenacl.SecretBox(key);

    final encrypted = box.encrypt(message);

    return [...encrypted.nonce, ...encrypted.cipherText];
  }

  List<int> symDecrypt(List<int> key, List<int> encryptedMessage) {
    final box = pinenacl.SecretBox(key);

    return box.decrypt(
      encryptedMessage.sublist(24) as Uint8List,
      nonce: encryptedMessage.sublist(0, 24) as Uint8List?,
    );
  }

  static List<int> generateRandomKey() {
    return pinenacl.PineNaClUtils.randombytes(pinenacl.SecretBox.keyLength);
  }

  List<int> generateOneTimeKey() {
    return pinenacl.PineNaClUtils.randombytes(pinenacl.SecretBox.keyLength);
  }

  static List<int> generateSeed() {
    return pinenacl.PineNaClUtils.randombytes(32);
  }

  List<int> encrypt(List<int> message, List<int> theirPublicKey) {
    final box = pinenacl.Box(
      myPrivateKey: sk,
      theirPublicKey: pinenacl.PublicKey(theirPublicKey),
    );

    final encrypted = box.encrypt(message);

    return [...encrypted.nonce, ...encrypted.cipherText];
  }

  List<int> decrypt(List<int> encryptedMessage, List<int> theirPublicKey) {
    final box = pinenacl.Box(
      myPrivateKey: sk,
      theirPublicKey: pinenacl.PublicKey(theirPublicKey),
    );

    final decrypted = box.decrypt(
      pinenacl.EncryptedMessage(
        nonce: encryptedMessage.sublist(0, 24),
        cipherText: encryptedMessage.sublist(24),
      ),
    );

    return decrypted;
  }
}
