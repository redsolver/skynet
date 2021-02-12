import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:crypto/crypto.dart';

import 'package:cryptography/cryptography.dart' hide sha1;
import 'package:encode_endian/base.dart';
import 'package:encode_endian/encode_endian.dart';
import 'package:password_hash/password_hash.dart';

import 'package:pinenacl/api.dart' as pinenacl;
import 'package:pinenacl/public.dart' as pinenacl;

import 'package:http/http.dart' as http;
import 'package:pinenacl/secret.dart' as pinenacl;
import 'package:pinenacl/utils.dart';
import 'blake2b/blake2b_hash.dart';
import 'file.dart';
import 'upload.dart';

import 'registry.dart';
import 'config.dart';

// FILEID_V1 represents version 1 of the FileID object
const FILEID_V1 = 1;

// FileType is the type of the file
enum FileType {
  Invalid, // 0 is invalid
  PublicUnencrypted,
}

extension FileTypeID on FileType {
  int toID() {
    if (this == FileType.PublicUnencrypted) {
      return 1;
    } else {
      return null;
    }
  }
}

FileType getFileTypeFromID(int id) {
  if (id == 1) return FileType.PublicUnencrypted;

  throw Exception('Invalid file type (Not PublicUnencrypted)');
}
// getFile will lookup the entry for given skappID and filename, if it exists it
// will try and download the file behind the skylink it has found in the entry.

Future<SkyFile> getFile(SkynetUser user, String datakey) async {
  // lookup the registry entry
  final existing = await getEntry(user, datakey);
  if (existing == null) {
    throw Exception('not found');
  }

  final skylink = String.fromCharCodes(existing.entry.data);

  // download the data in that Skylink
  final res = await http.get(Uri.https(SkynetConfig.host, '$skylink'));

  final metadata = json.decode(res.headers['skynet-file-metadata']);

  return SkyFile(
      content: res.bodyBytes,
      filename: metadata['filename'],
      type: res.headers['content-type']);
}

// setFile uploads a file and sets updates the registry
Future<bool> setFile(SkynetUser user, String datakey, SkyFile file) async {
  // upload the file to acquire its skylink
  final skylink = await uploadFile(file);

  SignedRegistryEntry existing;

  try {
    // fetch the current value to find out the revision
    final res = await getEntry(user, datakey);

    existing = res;
  } catch (e) {
    existing = null;
  }

  // TODO: we could (/should?) verify here

  // build the registry value
  final rv = RegistryEntry(
    datakey: datakey,
    data: utf8.encode(skylink),
    revision: (existing?.entry?.revision ?? 0) + 1,
  );

  // sign it
  final sig = await user.sign(rv.hash());

  final srv = SignedRegistryEntry(signature: sig, entry: rv);

  // update the registry
  final updated = await setEntry(user, datakey, srv);

  return updated;
}

// FileID represents a File
/* class FileID { // TODO Remove
  final version = FILEID_V1;
  String applicationID;
  FileType fileType;
  String filename;

  FileID({this.applicationID, this.fileType, this.filename}) {
    // validate file type
    if (fileType != FileType.PublicUnencrypted) {
      throw Exception('invalid file type');
    }
  }

  Map toJson() => {
        'version': version,
        'applicationid': applicationID,
        'filetype': fileType.toID(),
        'filename': filename,
      };

  FileID.fromJson(Map m) {
    applicationID = m['applicationid'];
    fileType = getFileTypeFromID(m['filetype']);
    filename = m['filename'];
  }

  Uint8List toBytes() => Uint8List.fromList([
        ...withPadding(version),
        ...withPadding(applicationID.length),
        ...utf8.encode(applicationID), // ?
        ...[fileType.toID(), 0, 0, 0, 0, 0, 0, 0],
        ...withPadding(filename.length),
        ...utf8.encode(filename),
      ]);

  Uint8List hash() {
    return Blake2bHash.hashWithDigestSize(
      256,
      toBytes(),
    );
  }
} */

List<int> withPadding(int i) {
  return encodeEndian(i, 8, endianType: EndianType.littleEndian);
}

int decodeUint8(List<int> bytes) {
  int result = 0;

  int position = 0;
  for (final int i in bytes) {
    result += i * pow(2, position);

    position += 8;
  }

  return result;
}

// User represents a user entity and can be used to sign.
class SkynetUser {
  String id;

  KeyPair keyPair;

  PublicKey publicKey;
  PrivateKey get privateKey => keyPair.privateKey;

  List<int> seed;

  pinenacl.PrivateKey sk;
  pinenacl.PublicKey pk;

  SkynetUser.fromId(String userId) {
    id = userId;
    publicKey = PublicKey(hex.decode(userId));
  }

  SkynetUser.fromSeed(List<int> usedSeed) {
    seed = usedSeed;

    // print('fromSeed $seed');

    /*  final skalice = pinenacl.PrivateKey.generate();

    final pkalice = skalice.publicKey;

    print(skalice);
    print(pkalice); */

    sk = pinenacl.PrivateKey.fromSeed(seed);

    // print(sk);
    //print(sk.publicKey);

    pk = sk.publicKey;

    keyPair = ed25519.newKeyPairFromSeedSync(PrivateKey(seed));

    publicKey = keyPair.publicKey;
    id = hex.encode(publicKey.bytes);
  }

  // see https://github.com/NebulousLabs/skynet-js/blob/f500b5cf879916b3ae26651d714d373414f82497/src/crypto.ts#L75
  static Uint8List skyIdSeedToEd25519Seed(String seedStringInBase64) {
    final generator =
        PBKDF2(/* hashAlgorithm: Sha256._() */ /* hashAlgorithm: sha1 */);

    return generator.generateKey(seedStringInBase64, '', 1000, 32);
  }

  // NOTE: username should be the user's email address as ideally it's unique
  @deprecated
  SkynetUser(String username, String password /* , {bool keepSeed = false} */) {
    final generator =
        PBKDF2(/* hashAlgorithm: Sha256._() */ hashAlgorithm: sha1);

    seed = generator.generateKey(password, username, 1000, 32);

    sk = pinenacl.PrivateKey.fromSeed(seed);
    pk = sk.publicKey;

    keyPair = ed25519.newKeyPairFromSeedSync(PrivateKey(seed));

    publicKey = keyPair.publicKey;
    id = hex.encode(publicKey.bytes);

    // if (!keepSeed) seed = null;
  }

  Future<Signature> sign(List<int> message) {
    return ed25519.sign(message, keyPair);
  }

  List<int> symEncrypt(List<int> key, List<int> message) {
    final box = pinenacl.SecretBox(key);

    final encrypted = box.encrypt(message);

    //print(encrypted.nonce.length);

    return [...encrypted.nonce, ...encrypted.cipherText];
  }

  List<int> symDecrypt(List<int> key, List<int> encryptedMessage) {
    final box = pinenacl.SecretBox(key);

    return box.decrypt(
      encryptedMessage.sublist(24),
      nonce: encryptedMessage.sublist(0, 24),
    );
  }

  static List<int> generateRandomKey() {
    return Utils.randombytes(pinenacl.SecretBox.keyLength);
  }

  List<int> generateOneTimeKey() {
    return Utils.randombytes(pinenacl.SecretBox.keyLength);
  }

  static List<int> generateSeed() {
    return Utils.randombytes(32);
  }

  List<int> encrypt(List<int> message, List<int> theirPublicKey) {
    // print('encrypt $seed');

    final box = pinenacl.Box(
      myPrivateKey: sk,
      theirPublicKey: pinenacl.PublicKey(theirPublicKey),
    );

/*     print(message); */

    final encrypted = box.encrypt(message);
/* 
    print(encrypted.nonce);
    print(encrypted.cipherText); */

    // print(encrypted.nonce.length);

    return [...encrypted.nonce, ...encrypted.cipherText];
  }

  List<int> decrypt(List<int> encryptedMessage, List<int> theirPublicKey) {
    // print(theirPublicKey);

    // final theirPubKeyInX25519 = pinenacl.convertPublicKey(theirPublicKey);

    // print(theirPubKeyInX25519);

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
