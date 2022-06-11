import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:skynet/skynet.dart';
import 'package:skynet/src/mysky/encrypted_files.dart';
import 'package:skynet/src/mysky/permission.dart';
import 'package:skynet/src/registry_classes.dart';
import '../mysky/json.dart' as file_impl;
import '../mysky/io.dart' as mysky_io_impl;

import 'package:skynet/src/mysky_provider/base.dart';

class NativeMySkyProvider extends MySkyProvider {
  final SkynetClient client;

  final Map<int, Completer<dynamic>> reqs = {};

  NativeMySkyProvider(this.client) : super(client);

  bool isLoggedIn = false;

  late SkynetUser skynetUser;

  Future<void> load(
    String dataDomain, {
    Map options = const {},
    String? seedPhrase,
  }) async {}

  var pendingPermissions = <Permission>[];

  Future<bool> checkLogin() async {
    return isLoggedIn;
  }

  Future<void> logout() async {
    // TODO Implement using get and delete functions
    return;
  }

  Future<bool> requestLoginAccess() async {
    return true;
  }

  Future<String> userId() async {
    return skynetUser.id;
  }

/*   Future<String> getEncryptedFileSeed(String path, bool isDirectory) async {
    print('getEncryptedFileSeed ${path} ${isDirectory}');
    return await call('getEncryptedFileSeed', [path, isDirectory]);
  } */

  Future<bool> setJSON(
    String path,
    dynamic data,
    int revision, {
    String filename = 'skynet-dart-sdk.json',
  }) async {
    return file_impl.setJSON(
      skynetUser,
      path,
      data,
      revision,
      filename: filename,
      skynetClient: client,
    );
  }

  Future<DataWithRevision<dynamic>> getJSON(
    String path, {
    String filename = 'skynet-dart-sdk.json',
  }) async {
    return file_impl.getJSONWithRevision(
      skynetUser.id,
      path,
      skynetClient: client,
    );
  }

  Future<mysky_io_impl.SetEncryptedJSONResponse> setJSONEncrypted(
    String path,
    dynamic data,
    int revision,
    // String filename = 'skynet-dart-sdk.json',
  ) async {
    final pathSeed = await getEncryptedFileSeed(path, false);
    client.logPath(path);
    return mysky_io_impl.setEncryptedJSON(
      skynetUser,
      path,
      data,
      revision,
      skynetClient: client,
      customPathSeed: pathSeed,
    );
  }

  // TODO Do some fancy caching where only revision numbers are checked and immutable skylink json contents are cached (global)
  Future<DataWithRevision<dynamic>> getJSONEncrypted(
    String path, {
    String filename = 'skynet-dart-sdk.json',
    String? userID,
    String? pathSeed,
  }) async {
    pathSeed ??= await getEncryptedFileSeed(path, false);

    return mysky_io_impl.getJSONEncrypted(
      userID ?? skynetUser.id,
      pathSeed,
      skynetClient: client,
    );
  }

  Future<bool> setRawDataEncrypted(
    String path,
    Uint8List data,
    int revision, {
    String? customEncryptedFileSeed,
  }
      // String filename = 'skynet-dart-sdk.json',
      ) async {
    final pathSeed =
        customEncryptedFileSeed ?? await getEncryptedFileSeed(path, false);
    return mysky_io_impl.setEncryptedRawData(
      skynetUser,
      path,
      data,
      revision,
      skynetClient: client,
      customPathSeed: pathSeed,
    );
  }

  // TODO Do some fancy caching where only revision numbers are checked and immutable skylink json contents are cached (global)
  Future<DataWithRevision<Uint8List?>> getRawDataEncrypted(
    String path, {
    String filename = 'skynet-dart-sdk.json',
    String? userID,
    String? pathSeed,
  }) async {
    pathSeed ??= await getEncryptedFileSeed(path, false);

    return mysky_io_impl.getEncryptedRawData(
      userID ?? skynetUser.id,
      pathSeed,
      skynetClient: client,
    );
  }

  @override
  Future<String> getEncryptedFileSeed(String path, bool isDirectory) {
    return mysky_io_impl.getEncryptedPathSeed(
      path,
      isDirectory,
      skynetUser.rawSeed,
    );
  }

  @override
  Future<Uint8List> signEncryptedRegistryEntry(
      RegistryEntry entry, String path) {
    // TODO: implement signEncryptedRegistryEntry
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> signRegistryEntry(RegistryEntry entry, String path) async {
    return Uint8List.fromList((await skynetUser.sign(entry.hash())).bytes);
  }
}
