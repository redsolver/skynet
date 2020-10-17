import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:crypto/crypto.dart';

import 'package:cryptography/cryptography.dart' hide sha1;
import 'package:encode_endian/base.dart';
import 'package:encode_endian/encode_endian.dart';
import 'package:password_hash/password_hash.dart';

import 'package:http/http.dart' as http;
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

// getFile will lookup the entry for given skappID and filename, if it exists it
// will try and download the file behind the skylink it has found in the entry.

Future<SkyFile> getFile(User user, FileID fileID) async {
  // lookup the registry entry
  final existing = await lookupRegistry(user, fileID);
  if (existing == null) {
    throw Exception('not found');
  }

  final skylink = String.fromCharCodes(existing.value.data);

  // download the data in that Skylink
  final res = await http.get(Uri.https(SkynetConfig.host, '$skylink'));

  final metadata = json.decode(res.headers['skynet-file-metadata']);

  return SkyFile(
      content: res.bodyBytes,
      filename: metadata['filename'],
      type: res.headers['content-type']);
}

// setFile uploads a file and sets updates the registry
Future<bool> setFile(User user, FileID fileID, SkyFile file) async {
  // upload the file to acquire its skylink
  final skylink = await uploadFile(file);

  SignedRegistryValue existing;

  try {
    // fetch the current value to find out the revision
    final res = await lookupRegistry(user, fileID);

    existing = res;
  } catch (e) {
    existing = null;
  }

  // TODO: we could (/should?) verify here

  // build the registry value
  final rv = RegistryValue(
    tweak: fileID.hash(),
    data: utf8.encode(skylink),
    revision: (existing?.value?.revision ?? 0) + 1,
  );

  // sign it
  final sig = await user.sign(rv.hash());

  final srv = SignedRegistryValue(signature: sig, value: rv);

  // update the registry
  final updated = await updateRegistry(user, fileID, srv);

  return updated;
}

// FileID represents a File
class FileID {
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

  Uint8List hash() {
    final list = Uint8List.fromList([
      ...withPadding(version),
      ...withPadding(applicationID.length),
      ...utf8.encode(applicationID), // ?
      ...[fileType.toID(), 0, 0, 0, 0, 0, 0, 0],
      ...withPadding(filename.length),
      ...utf8.encode(filename),
    ]);

    final hash = Blake2bHash.hashWithDigestSize(
      256,
      list,
    );

    return hash;
  }
}

List<int> withPadding(int i) {
  return encodeEndian(i, 8, endianType: EndianType.littleEndian);
}

// User represents a user entity and can be used to sign.
class User {
  String id;

  KeyPair keyPair;

  PublicKey publicKey;
  PrivateKey get privateKey => keyPair.privateKey;

  User.fromId(String userId) {
    id = userId;
    publicKey = PublicKey(hex.decode(userId));
  }

  // NOTE: username should be the user's email address as ideally it's unique
  User(String username, String password) {
    final generator =
        PBKDF2(/* hashAlgorithm: Sha256._() */ hashAlgorithm: sha1);

    final seed = generator.generateKey(password, username, 1000, 32);

    keyPair = ed25519.newKeyPairFromSeedSync(PrivateKey(seed));

    publicKey = keyPair.publicKey;
    id = hex.encode(publicKey.bytes);
  }

  Future<Signature> sign(List<int> message) {
    return ed25519.sign(message, keyPair);
  }
}
