import 'dart:typed_data';

import 'package:skynet/src/file.dart';
import 'package:skynet/src/registry_classes.dart';
import 'data_with_revision.dart';
import 'resolve.dart' as resolve_impl;
import 'skydb.dart' as skydb_impl;
import 'registry.dart' as registry_impl;
import 'upload.dart' as upload_impl;
import 'mysky/json.dart' as file_impl;
import 'user.dart';

class SkynetClient {
  late final String portalHost;

  late final _SkynetClientUpload upload;
  late final _SkynetClientSkyDB skydb;
  late final _SkynetClientRegistry registry;
  late final _SkynetClientFile file;

  SkynetClient([String portal = 'siasky.net']) {
    portalHost = portal; // TODO Auto-detection and remove .hns.
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
    Map data,
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
  }) =>
      registry_impl.getEntry(
        user,
        datakey,
        hashedDatakey: hashedDatakey,
        timeoutInSeconds: timeoutInSeconds,
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

  Future<String?> uploadDirectory(
    Map<String, Stream<List<int>>> fileStreams,
    Map<String, int> lengths,
    String fname,
  ) =>
      upload_impl.uploadDirectory(
        fileStreams,
        lengths,
        fname,
        skynetClient: _skynetClient,
      );
}
