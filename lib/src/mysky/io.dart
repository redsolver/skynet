import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:pinenacl/api.dart';
import 'package:skynet/src/client.dart';
import 'package:skynet/src/crypto.dart';
import 'package:skynet/src/data_with_revision.dart';
import 'package:skynet/src/file.dart';
import 'package:skynet/src/mysky/json.dart';
import 'package:skynet/src/registry_classes.dart';
import 'package:skynet/src/user.dart';

import 'encrypted_files.dart';

// ! skynet-js stuff

// ===============
// Encrypted Files
// ===============

/**
   * Lets you get the share-able path seed, which can be passed to
   * file.getEncryptedJSON. Requires read permission on the path.
   *
   * @param path - The given path.
   * @param isDirectory - Whether the path is a directory.
   * @returns - The seed for the path.
   */
/*   async getEncryptedFileSeed(path: string, isDirectory: boolean): Promise<string> {
    validateString("path", path, "parameter");
    validateBoolean("isDirectory", isDirectory, "parameter");

    return await this.connector.connection.remoteHandle().call("getEncryptedFileSeed", path, isDirectory);
  }
 */
/**
   * Gets Encrypted JSON at the given path through MySky, if the user has given Read permissions to do so.
   *
   * @param path - The data path.
   * @param [customOptions] - Additional settings that can optionally be set.
   * @returns - An object containing the decrypted json data.
   */

Future<DataWithRevision<dynamic>> getEncryptedJSONWithRevision(
  SkynetUser skynetUser,
  String path, {
  // String? pathSeed,
  required SkynetClient skynetClient,
}) async {
  try {
    final pathSeed =
        await getEncryptedFileSeed(path, false, skynetUser.rawSeed);

    final dataKey = deriveEncryptedFileTweak(pathSeed);
    final encryptionKey = deriveEncryptedFileKeyEntropy(pathSeed);

    // lookup the registry entry
    final existing = await skynetClient.registry.getEntry(
      skynetUser,
      '',
      timeoutInSeconds: 10,
      hashedDatakey: dataKey,
    );
    if (existing == null) {
      throw Exception('not found');
    }

    final skylink = decodeSkylinkFromRegistryEntry(existing.entry.data);

    // download the data in that Skylink
    final res = await skynetClient.httpClient.get(
      Uri.https(skynetClient.portalHost, '$skylink'),
      headers: skynetClient.headers,
    );

    final data = decryptJSONFile(res.bodyBytes, encryptionKey);
    // print(json.encode(data));

    if (data.containsKey('_data')) {
      return DataWithRevision(data['_data'], existing.entry.revision);
    }
    return DataWithRevision(data, existing.entry.revision);
  } catch (e) {
    print(e);
    return DataWithRevision(null, -1);
  }
}

Future<DataWithRevision<dynamic>> getJSONEncrypted(
  String userId,
  String pathSeed, {
  // String? pathSeed,
  required SkynetClient skynetClient,
}) async {
  try {
    final dataKey = deriveEncryptedFileTweak(pathSeed);
    final encryptionKey = deriveEncryptedFileKeyEntropy(pathSeed);

    // lookup the registry entry
    final existing = await skynetClient.registry.getEntry(
      SkynetUser.fromId(userId),
      '',
      timeoutInSeconds: 10,
      hashedDatakey: dataKey,
    );
    if (existing == null) {
      throw Exception('not found');
    }

    final skylink = decodeSkylinkFromRegistryEntry(existing.entry.data);

    // download the data in that Skylink
    final res = await skynetClient.httpClient.get(
      Uri.https(skynetClient.portalHost, '$skylink'),
      headers: skynetClient.headers,
    );

    final data = decryptJSONFile(res.bodyBytes, encryptionKey);
    // print(json.encode(data));

    if (data.containsKey('_data')) {
      return DataWithRevision(data['_data'], existing.entry.revision);
    }
    return DataWithRevision(data, existing.entry.revision);
  } catch (e) {
    print(e);
    return DataWithRevision(null, -1);
  }
}

/*   async getEncryptedJSON(path: string, customOptions?: CustomGetJSONOptions): Promise<EncryptedJSONResponse> {
    validateString("path", path, "parameter");
    validateOptionalObject("customOptions", customOptions, "parameter", defaultGetJSONOptions);

    const opts = {
      ...defaultGetJSONOptions,
      ...this.connector.client.customOptions,
      ...customOptions,
    };

    // Call MySky which checks for read permissions on the path.
    const publicKey = await this.userID();
    const pathSeed = await this.getEncryptedFileSeed(path, false);
    const dataKey = deriveEncryptedFileTweak(pathSeed);
    opts.hashedDataKeyHex = true; // Do not hash the tweak anymore.
    const encryptionKey = deriveEncryptedFileKeyEntropy(pathSeed);

    const { data } = await this.connector.client.db.getRawBytes(publicKey, dataKey, opts);
    if (data === null) {
      return { data: null };
    }
    const { _data: json } = decryptJSONFile(data, encryptionKey);

    return { data: json };
  }
 */
/**
   * Sets Encrypted JSON at the given path through MySky, if the user has given Write permissions to do so.
   *
   * @param path - The data path.
   * @param json - The json to encrypt and set.
   * @param [customOptions] - Additional settings that can optionally be set.
   * @returns - An object containing the original json data.
   */
Future<bool> setEncryptedJSON(
  SkynetUser skynetUser, // Derived from discoverable seed
  String path,
  dynamic jsonData,
  int revision, {
  required SkynetClient skynetClient,
}
    // int revision,
    ) async {
/*     validateString("path", path, "parameter");
    validateObject("json", json, "parameter");
    validateOptionalObject("customOptions", customOptions, "parameter", defaultSetJSONOptions); */

/*     const opts = {
      ...defaultSetJSONOptions,
      ...this.connector.client.customOptions,
      ...customOptions,
    }; */

  // Call MySky which checks for read permissions on the path.
  /* final publicKey = skynetUser
      .id; */

  final pathSeed = await getEncryptedFileSeed(path, false, skynetUser.rawSeed);
  final dataKey = deriveEncryptedFileTweak(pathSeed);
  final encryptionKey = deriveEncryptedFileKeyEntropy(pathSeed);

  // Pad and encrypt json file.
  final fullData = {'_data': jsonData, '_v': ENCRYPTED_JSON_RESPONSE_VERSION};
  final data = encryptJSONFile(fullData, encryptionKey);

  /* final entry = await getOrCreateRawBytesRegistryEntry(this.connector.client, publicKey, dataKey, data, opts);

    // Call MySky which checks for write permissions on the path.
    final signature = await this.signEncryptedRegistryEntry(entry, path); */

  final skylink = await (skynetClient.upload.uploadFile(
    SkyFile(
      content: data,
      filename: 'dk:${dataKey}',
      type: 'application/octet-stream',
    ),
  ));

  // print('skylink $skylink');

  if (skylink == null) {
    throw 'Upload failed';
  }

  // build the registry value
  final rv = RegistryEntry(
    datakey: null,
    data: utf8.encode(skylink) as Uint8List,
    revision: revision, //(existing?.entry.revision ?? 0) + 1,
  );

  rv.hashedDatakey = Uint8List.fromList(hex.decode(dataKey));

  // sign it
  final sig = await skynetUser.sign(rv.hash());

  final srv = SignedRegistryEntry(signature: sig, entry: rv);

  // update the registry
  final updated = await skynetClient.registry.setEntryRaw(
    skynetUser,
    '',
    srv,
    hashedDatakey: dataKey,
  );

  return updated;
}

// ! MySky stuff

Future<String> getEncryptedFileSeed(
    String path, bool isDirectory, Uint8List seed) async {
  // log("Entered getEncryptedFileSeed");

  // Check with the permissions provider that we have permission for this request.

  // this.checkPermission(path, PermCategory.Hidden, PermType.Read);

  // Get the seed.

/*     const seed = checkStoredSeed();
    if (!seed) {
      throw new Error("User seed not found");
    } */

  /* final seed = validatePhrase(phrase);

  final s1 = sha512.convert(utf8.encode('root discoverable key')).bytes;
  final s2 = sha512.convert(seed).bytes;

  final bytes = sha512.convert([...s1, ...s2]).bytes.sublist(0, 32);

  return Uint8List.fromList(bytes); */

  // Compute the root path seed.

  final bytes = Uint8List.fromList([
    ...sha512.convert(utf8.encode('encrypted filesystem path seed')).bytes,
    ...sha512.convert(seed).bytes
  ]);

  final rootPathSeed = hex.encode(
      sha512.convert(bytes).bytes.sublist(0, ENCRYPTION_PATH_SEED_LENGTH));

  // Compute the child path seed.

  final childPathSeed =
      deriveEncryptedFileSeed(rootPathSeed, path, isDirectory);

  return childPathSeed;
}

/*     Future<Uint8List> signEncryptedRegistryEntry(entry: RegistryEntry, path: string): Promise<Uint8Array> {
    return this.signRegistryEntryHelper(entry, path, PermCategory.Hidden);
  } */

// ================
// Internal Methods
// ================

/*   async signRegistryEntryHelper(entry: RegistryEntry, path: string, category: PermCategory): Promise<Uint8Array> {
    log("Entered signRegistryEntry");


      this.checkPermission(path, category, PermType.Write);

    // Get the seed.

    const seed = checkStoredSeed();
    if (!seed) {
      throw new Error("User seed not found");
    }



    const { privateKey } = genKeyPairFromSeed(seed);
    // Sign the entry.
    const signature = await signEntry(privateKey, entry, true);
    
    } */
