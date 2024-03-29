import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:skynet/src/file.dart';
import 'package:skynet/src/registry_classes.dart';
import 'package:skynet/src/utils/detect_portal/detect_portal.dart';
import 'data_with_revision.dart';
import 'resolve.dart' as resolve_impl;
import 'skydb.dart' as skydb_impl;
import 'registry.dart' as registry_impl;
import 'upload.dart' as upload_impl;
import 'mysky/json.dart' as file_impl;
import 'mysky/io.dart' as mysky_io_impl;
import 'user.dart';
import 'package:cross_file_dart/cross_file_dart.dart' show XFileDart;

import 'http_client/client_stub.dart'
    if (dart.library.html) 'http_client/browser_client.dart'
    if (dart.library.io) 'http_client/io_client.dart';

class SkynetClient {
  late final String portalHost;

  late final _SkynetClientUpload upload;
  late final _SkynetClientSkyDB skydb;
  late final _SkynetClientRegistry registry;
  late final _SkynetClientFile file;

  late final BaseClient httpClient;
  late final Map<String, String>? headers;

  SkynetClient({String? portal, String? cookie}) {
    portal ??= detectSkynetPortal();

    if (cookie != null) {
      headers = {'cookie': cookie};
    } else {
      headers = null;
    }

    httpClient = createClient();

    portalHost = portal;

    upload = _SkynetClientUpload(this);
    skydb = _SkynetClientSkyDB(this);
    registry = _SkynetClientRegistry(this);
    file = _SkynetClientFile(this);
  }

  String? resolveSkylink(String? link, {bool trusted = false}) =>
      resolve_impl.resolveSkylink(
        link,
        trusted: trusted,
        skynetClient: this,
      );
}

class _SkynetClientFile {
  final SkynetClient _skynetClient;

  _SkynetClientFile(this._skynetClient);

  Future<dynamic?> getJSON(
    String userId,
    String path,
  ) =>
      file_impl.getJSON(
        userId,
        path,
        skynetClient: _skynetClient,
      );

  Future<DataWithRevision<dynamic?>> getJSONWithRevision(
    String userId,
    String path,
  ) =>
      file_impl.getJSONWithRevision(
        userId,
        path,
        skynetClient: _skynetClient,
      );

  Future<bool> setJSON(
    SkynetUser skynetUser,
    String path,
    dynamic data,
    int revision, {
    String filename = 'skynet-dart-sdk.json',
  }) =>
      file_impl.setJSON(
        skynetUser,
        path,
        data,
        revision,
        filename: filename,
        skynetClient: _skynetClient,
      );

  Future<bool> setEncryptedJson(
    SkynetUser skynetUser,
    String path,
    dynamic data,
    int revision,
  ) =>
      mysky_io_impl.setEncryptedJSON(
        skynetUser,
        path,
        data,
        revision,
        skynetClient: _skynetClient,
      );

  Future<DataWithRevision<dynamic>> getEncryptedJSONWithRevision(
    SkynetUser skynetUser,
    String path,
    // {String? pathSeed}
  ) =>
      mysky_io_impl.getEncryptedJSONWithRevision(
        skynetUser,
        path,
        // pathSeed: pathSeed,
        skynetClient: _skynetClient,
      );

  Future<DataWithRevision<dynamic>> getJSONEncrypted(
    String userId,
    String pathSeed,
  ) =>
      mysky_io_impl.getJSONEncrypted(
        userId,
        pathSeed,
        skynetClient: _skynetClient,
      );

  Future<DataWithRevision<SkyFile>> getSkyFile(
    String userId,
    String path,
  ) =>
      file_impl.getSkyFile(
        userId,
        path,
        skynetClient: _skynetClient,
      );
}

class _SkynetClientRegistry {
  final SkynetClient _skynetClient;

  _SkynetClientRegistry(this._skynetClient);

  Future<SignedRegistryEntry?> getEntry(
    SkynetUser user,
    String datakey, {
    String? hashedDatakey,
    int timeoutInSeconds = 10,
    bool verifySignature = true,
  }) =>
      registry_impl.getEntry(
        user,
        datakey,
        hashedDatakey: hashedDatakey,
        timeoutInSeconds: timeoutInSeconds,
        verifySignature: verifySignature,
        skynetClient: _skynetClient,
      );

  Future<bool> setEntryRaw(
    SkynetUser user,
    String datakey,
    SignedRegistryEntry srv, {
    String? hashedDatakey,
  }) =>
      registry_impl.setEntryRaw(
        user,
        datakey,
        srv,
        hashedDatakey: hashedDatakey,
        skynetClient: _skynetClient,
      );

  Future<bool> setEntry(
    SkynetUser user,
    String datakey,
    Uint8List value, {
    String? hashedDatakey,
    int? revision,
  }) =>
      registry_impl.setEntryHelper(
        user,
        datakey,
        value,
        hashedDatakey: hashedDatakey,
        revision: revision,
        skynetClient: _skynetClient,
      );
}

class _SkynetClientSkyDB {
  final SkynetClient _skynetClient;

  _SkynetClientSkyDB(this._skynetClient);

  Future<SkyFile> getFile(
    SkynetUser user,
    String datakey, {
    int timeoutInSeconds = 10,
    String? hashedDatakey,
  }) =>
      skydb_impl.getFile(
        user,
        datakey,
        hashedDatakey: hashedDatakey,
        timeoutInSeconds: timeoutInSeconds,
        skynetClient: _skynetClient,
      );

  Future<DataWithRevision<SkyFile>> getFileWithRevision(
    SkynetUser user,
    String datakey, {
    int timeoutInSeconds = 10,
    String? hashedDatakey,
  }) =>
      skydb_impl.getFileWithRevision(
        user,
        datakey,
        hashedDatakey: hashedDatakey,
        timeoutInSeconds: timeoutInSeconds,
        skynetClient: _skynetClient,
      );

  Future<bool> setFile(
    SkynetUser user,
    String datakey,
    SkyFile file, {
    String? hashedDatakey,
  }) =>
      skydb_impl.setFile(
        user,
        datakey,
        file,
        hashedDatakey: hashedDatakey,
        skynetClient: _skynetClient,
      );
}

class _SkynetClientUpload {
  final SkynetClient _skynetClient;

  _SkynetClientUpload(this._skynetClient);

  Future<String?> uploadFile(SkyFile file) => upload_impl.uploadFile(
        file,
        skynetClient: _skynetClient,
      );

  Future<String?> uploadFileWithStream(
    SkyFile file,
    int length,
    Stream<List<int>> readStream,
  ) =>
      upload_impl.uploadFileWithStream(
        file,
        length,
        readStream,
        skynetClient: _skynetClient,
      );

  Future<String?> uploadLargeFile(
    XFileDart file, {
    Function(double)? onProgress,
    String? filename,
    /* Function()? onComplete, */
  }) =>
      upload_impl.uploadLargeFile(
        file,
        onProgress: onProgress,
        /* onComplete: onComplete, */
        skynetClient: _skynetClient,
        filename: filename,
      );

  Future<String?> uploadDirectory(
    Map<String, Stream<List<int>>> fileStreams,
    Map<String, int> lengths,
    String fname, {
    List<String>? tryFiles,
    Map<String, String>? errorPages,
  }) =>
      upload_impl.uploadDirectory(
        fileStreams,
        lengths,
        fname,
        skynetClient: _skynetClient,
        tryFiles: tryFiles,
        errorPages: errorPages,
      );
}
