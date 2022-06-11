import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:skynet/src/file.dart';
import 'package:skynet/src/registry_classes.dart';
import 'package:skynet/src/utils/detect_portal/detect_portal.dart';
import 'package:skynet/src/utils/url.dart';
import 'package:stash/stash_api.dart';
import 'data_with_revision.dart';
import 'resolve.dart' as resolve_impl;
import 'pin.dart' as pin_impl;
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
  late String portalHost;
  late String portalProtocol = 'https';

  late final _SkynetClientUpload upload;
  late final _SkynetClientSkyDB skydb;
  late final _SkynetClientRegistry registry;
  late final _SkynetClientFile file;
  late final _SkynetClientPortalAccount portalAccount;

  late final Vault<String>? _usedMySkyPaths;

  late final BaseClient httpClient;
  late Map<String, String>? headers;

  final trustedDomains = <String>[];

  void addTrustedDomain(String? url) {
    if (url == null) return;
    if (url.startsWith('http')) {
      trustedDomains.add(Uri.parse(url).host);
    } else {
      trustedDomains.add(url);
    }
  }

  void logPath(String path) {
    if (_usedMySkyPaths == null) return;
    final key = base64Url.encode(sha1.convert(utf8.encode(path)).bytes);
    _usedMySkyPaths?.putIfAbsent(key, path);
  }

  SkynetClient(
      {String? portal, String? cookie, Vault<String>? usedMySkyPathsVault}) {
    _usedMySkyPaths = usedMySkyPathsVault;
    portal ??= detectSkynetPortal();

    if (cookie != null) {
      headers = {'cookie': cookie};
    } else {
      headers = null;
    }

    httpClient = createClient();

    final parts = portal.split('://');
    if (parts.length == 1) {
      portalHost = parts.first;
    } else {
      portalProtocol = parts.first;
      portalHost = parts.last;
    }

    upload = _SkynetClientUpload(this);
    skydb = _SkynetClientSkyDB(this);
    registry = _SkynetClientRegistry(this);
    file = _SkynetClientFile(this);
    portalAccount = _SkynetClientPortalAccount(this);
  }

  String? resolveSkylink(String? link,
          {bool trusted = false, bool isolated = false}) =>
      resolve_impl.resolveSkylink(
        link,
        trusted: trusted,
        isolated: isolated,
        skynetClient: this,
      );

  Future<pin_impl.PinResponse> pinSkylink(String skylink) =>
      pin_impl.pinSkylink(
        skylink,
        skynetClient: this,
      );

  String extractDomain(String fullDomain) {
    return extractDomainForPortal(portalHost, fullDomain);
  }
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

  Future<mysky_io_impl.SetEncryptedJSONResponse> setEncryptedJson(
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
    String? datakey,
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

  String getEntryLink(
    String userId,
    String datakey, {
    String? hashedDatakey,
  }) =>
      registry_impl.getEntryLink(
        userId,
        datakey,
        hashedDatakey: hashedDatakey,
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
    Stream<Uint8List> readStream, {
    Function(double)? onProgress,
  }) =>
      upload_impl.uploadFileWithStream(
        file,
        length,
        readStream,
        skynetClient: _skynetClient,
        onProgress: onProgress,
      );

  Future<String?> uploadLargeFile(
    XFileDart file, {
    Function(double)? onProgress,
    required String filename,
    required String fingerprint,
    Stream<Uint8List>? streamFileData,
    int? streamFileLength,
    /* Function()? onComplete, */
  }) =>
      upload_impl.uploadLargeFile(
        file,
        onProgress: onProgress,
        /* onComplete: onComplete, */
        skynetClient: _skynetClient,
        filename: filename,
        fingerprint: fingerprint,
        // streamFileName: streamFileName,
        streamFileData: streamFileData,
        streamFileLength: streamFileLength,
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

class _SkynetClientPortalAccount {
  final SkynetClient _skynetClient;

  _SkynetClientPortalAccount(this._skynetClient);

  Uri _getAccountsApiUri(String path) {
    return Uri.parse(
        '${_skynetClient.portalProtocol}://account.${_skynetClient.portalHost}$path');
  }

  Future<Map> getUserInfo() async {
    final res = await _skynetClient.httpClient.get(
      _getAccountsApiUri(
        '/api/user',
      ),
      headers: _skynetClient.headers,
    );
    return json.decode(res.body);
  }

  Future<Map> getStats() async {
    final res = await _skynetClient.httpClient.get(
      _getAccountsApiUri(
        '/api/user/stats',
      ),
      headers: _skynetClient.headers,
    );
    return json.decode(res.body);
  }

  Future<Map> getLimits() async {
    final res = await _skynetClient.httpClient.get(
      _getAccountsApiUri(
        '/api/limits',
      ),
      headers: _skynetClient.headers,
    );
    return json.decode(res.body);
  }

  Future<Map> getDownloadsList({int pageSize = 10, int offset = 0}) async {
    final res = await _skynetClient.httpClient.get(
      _getAccountsApiUri(
        '/api/user/downloads',
      ).replace(queryParameters: {
        'pageSize': pageSize.toString(),
        'offset': offset.toString(),
      }),
      headers: _skynetClient.headers,
    );
    return json.decode(res.body);
  }

  Future<Map> getUploadsList({int pageSize = 10, int offset = 0}) async {
    final res = await _skynetClient.httpClient.get(
      _getAccountsApiUri(
        '/api/user/uploads',
      ).replace(queryParameters: {
        'pageSize': pageSize.toString(),
        'offset': offset.toString(),
      }),
      headers: _skynetClient.headers,
    );
    return json.decode(res.body);
  }

  Future<void> unpinSkylink(String skylink) async {
    final res = await _skynetClient.httpClient.delete(
      _getAccountsApiUri(
        '/api/user/uploads/$skylink',
      ),
      headers: _skynetClient.headers,
    );
    if (res.statusCode != 204)
      throw 'Unpin failed: ${res.statusCode} ${res.body}';

    return;
  }
}
