/// The MIT License (MIT)
///
/// Copyright (c) 2020 Joseph N. Mutumi
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

/// Modified by redsolver, 2021

import 'dart:convert' show base64, utf8;
import 'dart:math' show min;
import 'dart:typed_data' show BytesBuilder, Uint8List;
import 'package:skynet/src/client.dart';
import 'package:tus_client/src/exceptions.dart';
import 'package:tus_client/src/store.dart';

import 'package:cross_file_dart/cross_file_dart.dart' show XFileDart;
import 'package:http/http.dart' as http;
import "package:path/path.dart" as p;

/// This class is used for creating or resuming uploads.
class SkynetTusClient {
  /// Version of the tus protocol used by the client. The remote server needs to
  /// support this version, too.
  static final tusVersion = "1.0.0";

  final SkynetClient skynetClient;

  /// The tus server Uri
  final Uri url;

  /// Storage used to save and retrieve upload URLs by its fingerprint.
  final TusStore? store;

  final XFileDart file;

  final Map<String, String>? metadata;

  /// Any additional headers
  final Map<String, String>? headers;

  /// The maximum payload size in bytes when uploading the file in chunks (512KB)
  final int maxChunkSize;

  int? _fileSize;

  String _fingerprint = "";

  String? _uploadMetadata;

  Uri? _uploadUrl;

  int? _offset;

  bool _pauseUpload = false;

  Future? _chunkPatchFuture;

  SkynetTusClient(
    this.url,
    this.file, {
    required this.skynetClient,
    this.store,
    this.headers,
    this.metadata = const {},
    this.maxChunkSize = 512 * 1024,
  }) {
    _fingerprint = generateFingerprint() ?? "";
    _uploadMetadata = generateMetadata();
  }

  /// Whether the client supports resuming
  bool get resumingEnabled => store != null;

  /// The URI on the server for the file
  Uri? get uploadUrl => _uploadUrl;

  /// The fingerprint of the file being uploaded
  String get fingerprint => _fingerprint;

  /// The 'Upload-Metadata' header sent to server
  String get uploadMetadata => _uploadMetadata ?? "";

  http.Client getHttpClient() => skynetClient.httpClient;

  /// Create a new [upload] throwing [ProtocolException] on server error
  create() async {
    _fileSize = await file.length();

    final client = getHttpClient();
    final createHeaders = Map<String, String>.from(headers ?? {})
      ..addAll({
        "Tus-Resumable": tusVersion,
        "Upload-Metadata": _uploadMetadata ?? "",
        "Upload-Length": "$_fileSize",
      });

    // print('createHeaders $createHeaders');

    final response = await client.post(url, headers: createHeaders);
    if (!(response.statusCode >= 200 && response.statusCode < 300) &&
        response.statusCode != 404) {
      throw ProtocolException(
          "unexpected status code (${response.statusCode}) while creating upload");
    }

    String urlStr = response.headers["location"] ?? "";
    if (urlStr.isEmpty) {
      throw ProtocolException(
          "missing upload Uri in response for creating upload");
    }

    // print('urlStr $urlStr');

    _uploadUrl = _parseUrl(urlStr);

    // print('_uploadUrl $_uploadUrl');
    store?.set(_fingerprint, _uploadUrl as Uri);
  }

  /// Check if possible to resume an already started upload
  Future<bool> resume() async {
    _fileSize = await file.length();
    _pauseUpload = false;

    if (!resumingEnabled) {
      return false;
    }

    _uploadUrl = await store?.get(_fingerprint);

    if (_uploadUrl == null) {
      return false;
    }
    return true;
  }

  /// Start or resume an upload in chunks of [maxChunkSize] throwing
  /// [ProtocolException] on server error
  Future<String> upload({
    Function(double)? onProgress,
    Function()? onComplete,
  }) async {
    if (!await resume()) {
      await create();
    }

    // get offset from server
    _offset = await _getOffset();

    int totalBytes = _fileSize as int;

    // start upload
    final client = getHttpClient();

    while (!_pauseUpload && (_offset ?? 0) < totalBytes) {
      //print('_offset $_offset');
      final uploadHeaders = Map<String, String>.from(headers ?? {})
        ..addAll({
          "Tus-Resumable": tusVersion,
          "Upload-Offset": "$_offset",
          "Content-Type": "application/offset+octet-stream"
        });

      // print('uploadHeaders $uploadHeaders');

      _chunkPatchFuture = client.patch(
        _uploadUrl as Uri,
        headers: uploadHeaders,
        body: await _getData(),
      );
      final response = await _chunkPatchFuture;
      _chunkPatchFuture = null;

      // check if correctly uploaded
      if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        throw ProtocolException(
            "unexpected status code (${response.statusCode}) while uploading chunk: ${response.body}");
      }

      int? serverOffset = _parseOffset(response.headers["upload-offset"]);
      if (serverOffset == null) {
        throw ProtocolException(
            "response to PATCH request contains no or invalid Upload-Offset header");
      }
      if (_offset != serverOffset) {
        throw ProtocolException(
            "response contains different Upload-Offset value ($serverOffset) than expected ($_offset)");
      }
      // print('body ${(response as http.Response).body}');

      // update progress
      if (onProgress != null) {
        onProgress((_offset ?? 0) / totalBytes * 100);
      }

      if (_offset == totalBytes) {
        if (onComplete != null) {
          onComplete();
        }
      }
    }

    final Uri? location = await store?.get(_fingerprint);

    if (location == null) {
      throw ProtocolException("upload location not found");
    }

    final finalHeaders = Map<String, String>.from(headers ?? {})
      ..addAll({
        "Tus-Resumable": "1.0.0",
      });

    final res = await skynetClient.httpClient.head(
      Uri.https(
        skynetClient.portalHost,
        '/skynet/tus/' + location.pathSegments.last,
      ),
      headers: finalHeaders,
    );

    if (res.statusCode != 200) {
      throw 'HTTP ${res.statusCode} on upload: ${res.body}';
    }

    final String uploadMetadata = res.headers['upload-metadata']!;

    final skylink = uploadMetadata.split(',').map((element) {
      return element.split(' ');
    }).firstWhere((element) => element[0] == 'Skylink')[1];

    this.onComplete();

    // TODO https://github.com/SkynetLabs/skynet-js/pull/154
    // return res.headers['skynet-skylink']!;
    return utf8.decode(base64.decode(skylink));
  }

  /// Pause the current upload
  pause() {
    _pauseUpload = true;
    _chunkPatchFuture?.timeout(Duration.zero, onTimeout: () {});
  }

  /// Actions to be performed after a successful upload
  void onComplete() {
    store?.remove(_fingerprint);
  }

  /// Override this method to customize creating file fingerprint
  String? generateFingerprint() {
    return file.path.replaceAll(RegExp(r"\W+"), '.');
  }

  /// Override this to customize creating 'Upload-Metadata'
  String generateMetadata() {
    final meta = Map<String, String>.from(metadata ?? {});

    if (!meta.containsKey("filename")) {
      meta["filename"] = p.basename(file.path);
    }

    return meta.entries
        .map((entry) =>
            entry.key + " " + base64.encode(utf8.encode(entry.value)))
        .join(",");
  }

  /// Get offset from server throwing [ProtocolException] on error
  Future<int> _getOffset() async {
    final client = getHttpClient();

    final offsetHeaders = Map<String, String>.from(headers ?? {})
      ..addAll({
        "Tus-Resumable": tusVersion,
      });
    final response =
        await client.head(_uploadUrl as Uri, headers: offsetHeaders);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw ProtocolException(
          "unexpected status code (${response.statusCode}) while resuming upload");
    }

    int? serverOffset = _parseOffset(response.headers["upload-offset"]);
    if (serverOffset == null) {
      throw ProtocolException(
          "missing upload offset in response for resuming upload");
    }
    return serverOffset;
  }

  /// Get data from file to upload
  Future<Uint8List> _getData() async {
    int start = _offset ?? 0;
    int end = (_offset ?? 0) + maxChunkSize;
    end = end > (_fileSize ?? 0) ? _fileSize ?? 0 : end;
    // final fileChunk = await file.openRead(start, end).first;
    var b = BytesBuilder();

    /* final fileChunk = */
    await for (final chunk in file.openRead(start, end)) {
      b.add(chunk);
    }

    final bytesRead = min(maxChunkSize, b.length);
    _offset = (_offset ?? 0) + bytesRead;
    return b.toBytes();
  }

  int? _parseOffset(String? offset) {
    if (offset == null || offset.isEmpty) {
      return null;
    }
    if (offset.contains(",")) {
      offset = offset.substring(0, offset.indexOf(","));
    }
    return int.tryParse(offset);
  }

  Uri _parseUrl(String urlStr) {
    if (urlStr.contains(",")) {
      urlStr = urlStr.substring(0, urlStr.indexOf(","));
    }
    Uri uploadUrl = Uri.parse(urlStr);
    if (uploadUrl.host.isEmpty) {
      uploadUrl = uploadUrl.replace(host: url.host);
    }
    if (uploadUrl.scheme.isEmpty) {
      uploadUrl = uploadUrl.replace(scheme: url.scheme);
    }
    return uploadUrl;
  }
}
