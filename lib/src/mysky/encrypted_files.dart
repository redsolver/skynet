import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:pinenacl/api.dart' as pinenacl;
import 'package:pinenacl/ed25519.dart' as pinenacl;
import 'package:pinenacl/src/authenticated_encryption/secret.dart' as pinenacl;
import 'package:skynet/src/utils/paths.dart';
import 'package:tuple/tuple.dart';

const ENCRYPTED_JSON_RESPONSE_VERSION = 1;

/**
 * The length of the encryption key.
 */
const ENCRYPTION_KEY_LENGTH = 32;

/**
 * The length of the metadata stored in encrypted files.
 */
const ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH = 16;

/**
 * The length of the random nonce, prepended to the encrypted bytes.
 */
const ENCRYPTION_NONCE_LENGTH = 24;

/**
 * The length of the overhead introduced by encryption.
 */
const ENCRYPTION_OVERHEAD_LENGTH = 16;

/**
 * The length of the hex-encoded share-able directory path seed.
 */
const ENCRYPTION_PATH_SEED_DIRECTORY_LENGTH = 128;

/**
 * The length of the hex-encoded share-able file path seed.
 */
const ENCRYPTION_PATH_SEED_FILE_LENGTH = 64;

// Descriptive salt that should not be changed.
const SALT_ENCRYPTED_CHILD = "encrypted filesystem child";

// Descriptive salt that should not be changed.
const SALT_ENCRYPTED_TWEAK = "encrypted filesystem tweak";

// Descriptive salt that should not be changed.
const SALT_ENCRYPTION = "encryption";

const HASH_LENGTH = 32;

/* export type EncryptedJSONResponse = {
  data: JsonData | null;
}; */

class DerivationPathObject {
  Uint8List pathSeed;
  bool directory;
  String name;

  DerivationPathObject({
    required this.pathSeed,
    required this.directory,
    required this.name,
  });
  String toString() =>
      'DerivationPathObject{${hex.encode(pathSeed)},$directory,$name}';
}

class EncryptedFileMetadata {
  // 8-bit uint.
  int version;

  EncryptedFileMetadata({required this.version});
}

/**
 * Decrypts the given bytes as an encrypted JSON file.
 *
 * @param data - The given raw bytes.
 * @param key - The encryption key.
 * @returns - The JSON data and metadata.
 * @throws - Will throw if the bytes could not be decrypted.
 */
dynamic decryptJSONFile(Uint8List data, Uint8List key) {
  /* // print(data.toString().replaceAll(' ', ''));
  if (key.length != ENCRYPTION_KEY_LENGTH) {
    throw 'wrong ENCRYPTION_KEY_LENGTH';
  }

  // Validate that the size of the data corresponds to a padded block.
  if (!checkPaddedBlock(data.length)) {
    throw "Expected parameter 'data' to be padded encrypted data, length was '${data.length}', nearest padded block is '${padFileSize(data.length)}'";
  }

  // Extract the nonce.
  final nonce = data.sublist(0, ENCRYPTION_NONCE_LENGTH);

  // Extract the unencrypted hidden field metadata.
  final metadataBytes = data.sublist(
    ENCRYPTION_NONCE_LENGTH,
    ENCRYPTION_NONCE_LENGTH + ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH,
  );

  final metadata = decodeEncryptedFileMetadata(metadataBytes);
  if (metadata.version != ENCRYPTED_JSON_RESPONSE_VERSION) {
    throw "Received unrecognized JSON response version '${metadata.version}' in metadata, expected '${ENCRYPTED_JSON_RESPONSE_VERSION}'";
  }

  // Decrypt the non-nonce part of the data.

  final box = pinenacl.SecretBox(key);

  var decryptedBytes = box.decrypt(
      pinenacl.ByteList(
        data.sublist(
          ENCRYPTION_NONCE_LENGTH + ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH,
        ),
      ),
      nonce: nonce);

  if (decryptedBytes == null) {
    throw "Could not decrypt given encrypted JSON file";
  }

  // Trim the 0-byte padding off the end.
  var paddingIndex = decryptedBytes.length;
  while (paddingIndex > 0 && decryptedBytes[paddingIndex - 1] == 0) {
    paddingIndex--;
  }
  decryptedBytes = decryptedBytes.sublist(0, paddingIndex); */

  //decryptedBytes =
  //     decryptedBytes.sublist(ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH);
  // Extract the metadata.
  final decryptRes = decryptRawData(data, key);

  // Parse the final decrypted message as json.
  // print(decryptedBytes.toString().replaceAll(' ', ''));
  final jsonData = json.decode(utf8.decode(decryptRes.item1));
  return {'_data': jsonData, '_v': decryptRes.item2.version};
}

/**
 * Encrypts the given JSON data and metadata.
 *
 * @param fullData - The given JSON data and metadata.
 * @param key - The encryption key.
 * @returns - The encrypted data.
 */
Uint8List encryptJSONFile(Map fullData, Uint8List key) {
  final dynamic _data = fullData['_data'];
  final int _v = fullData['_v'];

  /* validateObject("fullData._data", _data, "parameter");
  validateNumber("fullData._v", _v, "parameter"); */

  if (key.length != ENCRYPTION_KEY_LENGTH) {
    throw 'wrong ENCRYPTION_KEY_LENGTH';
  }

  // Stringify the json and convert to bytes.
  var data = utf8.encode(json.encode(_data));

  final res = encryptRawData(Uint8List.fromList(data), key);
  return res;

  // Add padding so that the final size will be a padded block. The overhead will be added by encryption and we add the nonce at the end.
  /* final finalSize = padFileSize(data.length) -
      ENCRYPTION_OVERHEAD_LENGTH -
      ENCRYPTION_NONCE_LENGTH; */
/*   final totalOverhead = ENCRYPTION_OVERHEAD_LENGTH +
      ENCRYPTION_NONCE_LENGTH +
      ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH;
  final finalSize = padFileSize(data.length + totalOverhead) - totalOverhead;

  data = Uint8List.fromList([...data, ...Uint8List(finalSize - data.length)]);

  // Generate a random nonce.
  final nonce = Uint8List.fromList(
      pinenacl.PineNaClUtils.randombytes(ENCRYPTION_NONCE_LENGTH));

  final box = pinenacl.SecretBox(key);

  // Encrypt the data.
  final encryptedBytes = box.encrypt(Uint8List.fromList(data), nonce: nonce);

  // Prepend the metadata.
  final metadata = EncryptedFileMetadata(version: _v);
  final metadataBytes = encodeEncryptedFileMetadata(metadata);
  // data = ;

  // Prepend the nonce to the final data.
  return Uint8List.fromList(nonce + metadataBytes + encryptedBytes.cipherText); */
}

Tuple2<Uint8List, EncryptedFileMetadata> decryptRawData(
    Uint8List data, Uint8List key) {
  if (key.length != ENCRYPTION_KEY_LENGTH) {
    throw 'wrong ENCRYPTION_KEY_LENGTH';
  }

  // Validate that the size of the data corresponds to a padded block.
  if (!checkPaddedBlock(data.length)) {
    throw "Expected parameter 'data' to be padded encrypted data, length was '${data.length}', nearest padded block is '${padFileSize(data.length)}'";
  }

  // Extract the nonce.
  final nonce = data.sublist(0, ENCRYPTION_NONCE_LENGTH);

  // Extract the unencrypted hidden field metadata.
  final metadataBytes = data.sublist(
    ENCRYPTION_NONCE_LENGTH,
    ENCRYPTION_NONCE_LENGTH + ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH,
  );

  final metadata = decodeEncryptedFileMetadata(metadataBytes);
  if (metadata.version != ENCRYPTED_JSON_RESPONSE_VERSION) {
    throw "Received unrecognized JSON response version '${metadata.version}' in metadata, expected '${ENCRYPTED_JSON_RESPONSE_VERSION}'";
  }

  // Decrypt the non-nonce part of the data.

  final box = pinenacl.SecretBox(key);

  var decryptedBytes = box.decrypt(
      pinenacl.ByteList(
        data.sublist(
          ENCRYPTION_NONCE_LENGTH + ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH,
        ),
      ),
      nonce: nonce);

  if (decryptedBytes == null) {
    throw "Could not decrypt given encrypted JSON file";
  }

  // Trim the 0-byte padding off the end.
  var paddingIndex = decryptedBytes.length;
  while (paddingIndex > 0 && decryptedBytes[paddingIndex - 1] == 0) {
    paddingIndex--;
  }
  decryptedBytes = decryptedBytes.sublist(0, paddingIndex);

  //decryptedBytes =
  //     decryptedBytes.sublist(ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH);
  // Extract the metadata.

  // Parse the final decrypted message as json.
  // print(decryptedBytes.toString().replaceAll(' ', ''));
  return Tuple2(decryptedBytes, metadata);
}

/**
 * Encrypts the given JSON data and metadata.
 *
 * @param fullData - The given JSON data and metadata.
 * @param key - The encryption key.
 * @returns - The encrypted data.
 */
Uint8List encryptRawData(Uint8List data /* Map fullData */, Uint8List key,
    {int version = ENCRYPTED_JSON_RESPONSE_VERSION}) {
/*   final dynamic _data = fullData['_data'];
  final int _v = fullData['_v'];

  /* validateObject("fullData._data", _data, "parameter");
  validateNumber("fullData._v", _v, "parameter"); */

  if (key.length != ENCRYPTION_KEY_LENGTH) {
    throw 'wrong ENCRYPTION_KEY_LENGTH';
  }

  // Stringify the json and convert to bytes.
  var data = utf8.encode(json.encode(_data)); */

  // Add padding so that the final size will be a padded block. The overhead will be added by encryption and we add the nonce at the end.
  /* final finalSize = padFileSize(data.length) -
      ENCRYPTION_OVERHEAD_LENGTH -
      ENCRYPTION_NONCE_LENGTH; */
  final totalOverhead = ENCRYPTION_OVERHEAD_LENGTH +
      ENCRYPTION_NONCE_LENGTH +
      ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH;

  final finalSize = padFileSize(data.length + totalOverhead) - totalOverhead;

  data = Uint8List.fromList(data + Uint8List(finalSize - data.length));

  // Generate a random nonce.
  final nonce = Uint8List.fromList(
      pinenacl.PineNaClUtils.randombytes(ENCRYPTION_NONCE_LENGTH));

  final box = pinenacl.SecretBox(key);

  // Encrypt the data.
  final encryptedBytes = box.encrypt(Uint8List.fromList(data), nonce: nonce);

  // Prepend the metadata.
  final metadata = EncryptedFileMetadata(version: version);
  final metadataBytes = encodeEncryptedFileMetadata(metadata);
  // data = ;

  // Prepend the nonce to the final data.
  return Uint8List.fromList(nonce + metadataBytes + encryptedBytes.cipherText);
}

/**
 * Derives key entropy for the given path seed.
 *
 * @param pathSeed - The given path seed.
 * @returns - The key entropy.
 */
Uint8List deriveEncryptedFileKeyEntropy(String pathSeed) {
  final bytes = Uint8List.fromList([
    ...sha512.convert(utf8.encode(SALT_ENCRYPTION)).bytes,
    ...sha512.convert(utf8.encode(pathSeed)).bytes
  ]);
  final hashBytes = sha512.convert(bytes).bytes;
  // Truncate the hash to the size of an encryption key.
  return Uint8List.fromList(hashBytes.sublist(0, ENCRYPTION_KEY_LENGTH));
}

/**
 * Derives the encrypted file tweak for the given path seed.
 *
 * @param pathSeed - the given path seed.
 * @returns - The encrypted file tweak.
 */
String deriveEncryptedFileTweak(String pathSeed) {
  var hashBytes = sha512.convert([
    ...sha512.convert(utf8.encode(SALT_ENCRYPTED_TWEAK)).bytes,
    ...sha512.convert(utf8.encode(pathSeed)).bytes
  ]).bytes;
  // Truncate the hash or it will be rejected in skyd.
  hashBytes = hashBytes.sublist(0, HASH_LENGTH);
  return hex.encode(hashBytes);
}

/**
 * Derives the path seed for the relative path, given the starting path seed and
 * whether it is a directory. The path can be an absolute path if the root seed
 * is given.
 *
 * @param pathSeed - The given starting path seed.
 * @param subPath - The path.
 * @param isDirectory - Whether the path is a directory.
 * @returns - The path seed for the given path.
 */
String deriveEncryptedPathSeed(
    String pathSeed, String subPath, bool isDirectory) {
  // TODO pathSeed must be a hex string
  /* validateHexString("pathSeed", pathSeed, "parameter");
  validateString("subPath", subPath, "parameter");
  validateBoolean("isDirectory", isDirectory, "parameter"); */

  var pathSeedBytes = hex.decode(pathSeed);

  // print('deriveEncryptedFileSeed > $pathSeed');

  final sanitizedPath = sanitizePath(subPath);
  if (sanitizedPath == null) {
    throw 'Input subPath ${subPath} not a valid path';
  }
  final names = sanitizedPath.split('/');

  for (var index = 0; index < names.length; index++) {
    final name = names[index];
    final directory = index == names.length - 1 ? isDirectory : true;
    // print('deriveEncryptedFileSeed $name $directory');
    final derivationPathObj = DerivationPathObject(
      pathSeed: Uint8List.fromList(pathSeedBytes),
      directory: directory,
      name: name,
    );
    // print(derivationPathObj);
    final derivationPath = hashDerivationPathObject(derivationPathObj);
    // print('derivationPath ${hex.encode(derivationPath)}}');
    final bytes = Uint8List.fromList([
      ...sha512.convert(utf8.encode(SALT_ENCRYPTED_CHILD)).bytes,
      ...derivationPath
    ]);
    pathSeedBytes = sha512.convert(bytes).bytes;

    /*    print(
      'deriveEncryptedFileSeed > ' +
          hex.encode(
            pathSeedBytes.sublist(
              0,
              ENCRYPTION_PATH_SEED_LENGTH,
            ),
          ),
    ); */
  }
  // Truncate the path seed bytes for files only.
  if (!isDirectory) {
    // Divide `ENCRYPTION_PATH_SEED_FILE_LENGTH` by 2 since that is the final hex-encoded length.
    pathSeedBytes = pathSeedBytes.sublist(
        0, (ENCRYPTION_PATH_SEED_FILE_LENGTH / 2).round());
  }
  // Hex-encode the final output.
  return hex.encode(pathSeedBytes);

  // Truncate and hex-encode the final output.
  // return hex.encode(pathSeedBytes.sublist(0, ENCRYPTION_PATH_SEED_LENGTH));
}

/**
 * Hashes the derivation path object.
 *
 * @param obj - The given object containing the derivation path.
 * @returns - The hash.
 */
Uint8List hashDerivationPathObject(DerivationPathObject obj) {
  final bytes = new Uint8List.fromList(
      [...obj.pathSeed, obj.directory ? 1 : 0, ...utf8.encode(obj.name)]);
  return Uint8List.fromList(sha512.convert(bytes).bytes);
}

/**
 * To prevent analysis that can occur by looking at the sizes of files, all
 * encrypted files will be padded to the nearest "pad block" (after encryption).
 * A pad block is minimally 4 kib in size, is always a power of 2, and is always
 * at least 5% of the size of the file.
 *
 * For example, a 1 kib encrypted file would be padded to 4 kib, a 5 kib file
 * would be padded to 8 kib, and a 105 kib file would be padded to 112 kib.
 * Below is a short table of valid file sizes:
 *
 * ```
 *   4 KiB      8 KiB     12 KiB     16 KiB     20 KiB
 *  24 KiB     28 KiB     32 KiB     36 KiB     40 KiB
 *  44 KiB     48 KiB     52 KiB     56 KiB     60 KiB
 *  64 KiB     68 KiB     72 KiB     76 KiB     80 KiB
 *
 *  88 KiB     96 KiB    104 KiB    112 KiB    120 KiB
 * 128 KiB    136 KiB    144 KiB    152 KiB    160 KiB
 *
 * 176 KiB    192 Kib    208 KiB    224 KiB    240 KiB
 * 256 KiB    272 KiB    288 KiB    304 KiB    320 KiB
 *
 * 352 KiB    ... etc
 * ```
 *
 * Note that the first 20 valid sizes are all a multiple of 4 KiB, the next 10
 * are a multiple of 8 KiB, and each 10 after that the multiple doubles. We use
 * this method of padding files to prevent an adversary from guessing the
 * contents or structure of the file based on its size.
 *
 * @param initialSize - The size of the file.
 * @returns - The final size, padded to a pad block.
 * @throws - Will throw if the size would overflow the JS number type.
 */
int padFileSize(int initialSize) {
  final kib = 1 << 10;
  // Only iterate to 53 (the maximum safe power of 2).
  for (var n = 0; n < 53; n++) {
    if (initialSize <= (1 << n) * 80 * kib) {
      final paddingBlock = (1 << n) * 4 * kib;
      var finalSize = initialSize;
      if (finalSize % paddingBlock != 0) {
        finalSize = initialSize - (initialSize % paddingBlock) + paddingBlock;
      }
      return finalSize;
    }
  }
  // Prevent overflow. Max JS number size is 2^53-1.
  throw "Could not pad file size, overflow detected.";
/*   final kib = 1 << 10;
  for (var n = 0;; n++) {
    // Prevent overflow. Max JS number size is 2^53-1.
    if (n >= 53) {
      throw "Could not pad file size, overflow detected.";
    }
    if (initialSize <= (1 << n) * 80 * kib) {
      final paddingBlock = (1 << n) * 4 * kib;
      var finalSize = initialSize;
      if (finalSize % paddingBlock != 0) {
        finalSize = initialSize - (initialSize % paddingBlock) + paddingBlock;
      }
      return finalSize;
    }
  } */
}

/**
 * Checks if the given size corresponds to the correct padded block.
 *
 * @param size - The given file size.
 * @returns - Whether the size corresponds to a padded block.
 * @throws - Will throw if the size would overflow the JS number type.
 */
bool checkPaddedBlock(int size) {
  final kib = 1024;
  // Only iterate to 53 (the maximum safe power of 2).
  for (int n = 0; n < 53; n++) {
    if (size <= (1 << n) * 80 * kib) {
      final paddingBlock = (1 << n) * 4 * kib;
      return size % paddingBlock == 0;
    }
  }
  throw "Could not check padded file size, overflow detected.";
}

/**
 * Decodes the encoded encrypted file metadata.
 *
 * @param bytes - The encoded metadata.
 * @returns - The decoded metadata.
 * @throws - Will throw if the given bytes are of the wrong length.
 */
EncryptedFileMetadata decodeEncryptedFileMetadata(Uint8List bytes) {
  // Ensure input is correct length.
  if (bytes.length != ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH) {
    throw 'bytes.length != ENCRYPTION_METADATA_LENGTH';
  }

  final version = bytes[0];

  return EncryptedFileMetadata(
    version: version,
  );
}

/**
 * Encodes the given encrypted file metadata.
 *
 * @param metadata - The given metadata.
 * @returns - The encoded metadata bytes.
 * @throws - Will throw if the version does not fit in a byte.
 */
Uint8List encodeEncryptedFileMetadata(EncryptedFileMetadata metadata) {
  final bytes = Uint8List(ENCRYPTION_HIDDEN_FIELD_METADATA_LENGTH);

  // Encode the version
  if (metadata.version >= 1 << 8 || metadata.version < 0) {
    throw "Metadata version '${metadata.version}' could not be stored in a uint8";
  }
  // Don't need to use a DataView or worry about endianness for a uint8.
  bytes[0] = metadata.version;

  return bytes;
}
