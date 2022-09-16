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

import 'dart:async';
import 'dart:convert' show base64, utf8;
import 'dart:html';
import 'dart:math' show max, min;
import 'dart:typed_data' show BytesBuilder, Uint8List;
import 'package:skynet/src/client.dart';
import 'package:tus_client/src/exceptions.dart';
import 'package:tus_client/src/store.dart';

import 'package:cross_file_dart/cross_file_dart.dart' show XFileDart;
import 'package:http/http.dart' as http;
import "package:path/path.dart" as p;

/// This class is used for creating or resuming uploads.
class SkynetTusClientWeb {
  /// Version of the tus protocol used by the client. The remote server needs to
  /// support this version, too.
  static final tusVersion = "1.0.0";

  final SkynetClient skynetClient;

  /// The tus server Uri
  final Uri url;

  // final XFileDart file;

  final Map<String, String>? metadata;

  /// Any additional headers
  final Map<String, String>? headers;

  /// The maximum payload size in bytes when uploading the file in chunks (512KB)
  final int maxChunkSize;

  int? _fileSize;

  String? _uploadMetadata;

  Uri? _uploadUrl;

  late Uri uploadUrl;

  int? _offset;

  bool _pauseUpload = false;

  Future? _chunkPatchFuture;

  final int streamFileLength;
  String filename;

/*   Stream<Uint8List>? streamFileData;
  
  */

  SkynetTusClientWeb(
    this.url, {
    required this.skynetClient,
    // required String fingerprint,
    required this.filename,
    required this.streamFileLength,
    // required this.streamFileName,
    this.headers,
    /*  this.streamFileData,
    this.streamFileLength,
    this.streamFileName, */
    this.metadata = const {},
    this.maxChunkSize = 512 * 1024,
  }) {
    // _fingerprint = fingerprint;
    //  generateFingerprint() ?? "";
    _uploadMetadata = generateMetadata();
  }

  /// The 'Upload-Metadata' header sent to server
  String get uploadMetadata => _uploadMetadata ?? "";

  /// Create a new [upload] throwing [ProtocolException] on server error
  create() async {
    _fileSize = streamFileLength;

    // final client = getHttpClient();
    final createHeaders = Map<String, String>.from(headers ?? {})
      ..addAll({
        "Tus-Resumable": tusVersion,
        "Upload-Metadata": _uploadMetadata ?? "",
        "Upload-Length": "$_fileSize",
      });

    // print('createHeaders $createHeaders');

    final response =
        await skynetClient.httpClient.post(url, headers: createHeaders);

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
    uploadUrl = _uploadUrl!;
  }

  /// Start or resume an upload in chunks of [maxChunkSize] throwing
  /// [ProtocolException] on server error
  Future<String> upload(
    Stream<Blob> stream, {
    Function(double)? onProgress,
    Function()? onComplete,
  }) async {
    await create();

    // final updateStream = StreamController<Null>.broadcast();
    var temporaryCompleter = Completer();

    // var list = Uint8List(0);
    Blob blob = Blob([]);
    int totalBytes = _fileSize as int;

    stream.listen((event) {
      // print('got blob ${event.size}');
      blob = Blob([blob, event]);
      // updateStream.add(null);
      temporaryCompleter.complete();
      temporaryCompleter = Completer();

      /*     if (!(blob.size < maxChunkSize &&
          ((_offset ?? 0) + blob.size) != totalBytes)) {
        updateStream.add(null);
      } */
      // list = Uint8List.fromList(list + event);
      // list.addAll(event);
    });

    // bool streamClosed = false;

/*     if (streamFileData != null) {
      streamFileData!.listen((event) {
        list.addAll(event);
      })
        ..onDone(() {
          streamClosed = true;
        })
        ..onError((e) {
          throw 'Upload stream error $e';
        });
    } */

    // get offset from server
    _offset = 0; // await _getOffset();

    // start upload
    // final client = getHttpClient();

    while (!_pauseUpload && (_offset ?? 0) < totalBytes) {
      while (blob.size < maxChunkSize &&
          ((_offset ?? 0) + blob.size) != totalBytes) {
        /*       print(
            '${blob.size} < ${maxChunkSize} && ((${_offset} ?? 0) + list.length) != ${totalBytes}'); */
        await temporaryCompleter.future;

        // await Future.delayed(Duration(milliseconds: 10));
      }

      //print('_offset $_offset');
      final uploadHeaders = Map<String, String>.from(headers ?? {})
        ..addAll({
          "Tus-Resumable": tusVersion,
          "Upload-Offset": "$_offset",
          "Content-Type": "application/offset+octet-stream"
        });

      // print('uploadHeaders $uploadHeaders');

      /*     int start = _offset ?? 0;
    int end = (_offset ?? 0) + maxChunkSize;
    end = end > (_fileSize ?? 0) ? _fileSize ?? 0 : end;
    // final fileChunk = await file.openRead(start, end).first;
    var b = BytesBuilder();

    /* final fileChunk = */
    await for (final chunk in file.openRead(start, end)) {
      b.add(chunk);
    }

    final bytesRead = min(maxChunkSize, b.length);
    return b.toBytes(); */

      /* TODO  if (streamFileData != null) {
        while (list.length < maxChunkSize && !streamClosed) {
          await Future.delayed(Duration(milliseconds: 10));
        }
        final start = 0;
        final end = min(maxChunkSize, list.length);

        _chunkPatchFuture = client.patch(
          _uploadUrl as Uri,
          headers: uploadHeaders,
          body: Uint8List.fromList(list.sublist(start, end)),
        );
        list.removeRange(start, end);
      } else { */
      print('HTTP PATCH start $_uploadUrl');

      final completer = Completer<int>();

      final request = HttpRequest();
      request.withCredentials = skynetClient.withCredentials;

      /*    void handleEvent(dynamic event) {
        print('handleEvent $event');
      }
 */
      /*  request.onProgress.listen((event) {
        print('onProgress $event');
      });

      request.addEventListener('loadstart', handleEvent);
      request.addEventListener('load', handleEvent);
      request.addEventListener('loadend', handleEvent);
      request.addEventListener('progress', handleEvent);
      request.addEventListener('error', handleEvent);
      request.addEventListener('abort', handleEvent); */
      /*    request.upload.onProgress.listen((event) {
        print('onProgress $event');
      }); */
      request.open('PATCH', _uploadUrl.toString());

      /*  request.upload.onProgress.listen((event) {
        print('onProgress $event');
      }); */

      for (final entry in uploadHeaders.entries) {
        request.setRequestHeader(entry.key, entry.value);
      }

// upload progress event
/*       request.upload.addEventListener('progress', (e) {
        print('progress event');
        final event = (e as ProgressEvent);
        final progress = (event.loaded! / event.total!);
        print('uploadProgress $progress');
      }); */

// AJAX request finished event
      request.addEventListener('load', (e) {
        completer.complete(request.status);
        /* // HTTP status message
	console.log(request.status);

	// request.response will hold the response from the server
	console.log(request.response); */
      });

// send POST request to server side script
      final length = min(blob.size, maxChunkSize);
      _offset = (_offset ?? 0) + length;

      final data = blob.slice(0, length);

      request.send(Blob([data]));

      /* final res = await promiseToFuture<AxiosResponse>(request(AxiosSettings(
          method: 'PATCH',
          url: _uploadUrl.toString(),
          data: data,
          headers: uploadHeaders,
          onUploadProgress: allowInterop((p) {
            print('onUploadProgress $p');
          })))); */

      blob = blob.slice(length);

      // list = list.sublist(length);

      final statusCode = await completer.future;

      /*      _chunkPatchFuture = client.patch(
        _uploadUrl as Uri,
        headers: uploadHeaders,
        body: 
      ); */
      // }
      // final response = await _chunkPatchFuture;
      print('HTTP PATCH done');
      _chunkPatchFuture = null;

      // check if correctly uploaded
      if (!(statusCode >= 200 && statusCode < 300)) {
        throw ProtocolException(
            "unexpected status code (${statusCode}) while uploading chunk: ${request.response}");
      }

      int? serverOffset =
          _parseOffset(request.responseHeaders["upload-offset"]);
      if (serverOffset == null) {
        throw ProtocolException(
            "response to PATCH request contains no or invalid Upload-Offset header");
      }
      if (_offset != serverOffset) {
        throw ProtocolException(
            "response contains different Upload-Offset value ($serverOffset) than expected ($_offset)");
      }

      // update progress
      if (onProgress != null) {
        onProgress((_offset ?? 0) / totalBytes);
      }

      if (_offset == totalBytes) {
        if (onComplete != null) {
          onComplete();
        }
      }
    }

    final Uri? location = uploadUrl;

    if (location == null) {
      throw ProtocolException("upload location not found");
    }

    final finalHeaders = Map<String, String>.from(headers ?? {})
      ..addAll({
        "Tus-Resumable": "1.0.0",
      });

    final finalUri =
        location;

    final res = await skynetClient.httpClient.head(
      finalUri,
      headers: finalHeaders,
    );

    if (res.statusCode != 200) {
      throw 'HTTP ${res.statusCode} on upload: ${res.body}';
    }

    final String uploadMetadata = res.headers['upload-metadata']!;

    final skylink = uploadMetadata.split(',').map((element) {
      return element.split(' ');
    }).firstWhere((element) => element[0] == 'Skylink')[1];

    //this.onComplete();

    // TODO https://github.com/SkynetLabs/skynet-js/pull/154
    // return res.headers['skynet-skylink']!;
    return utf8.decode(base64.decode(skylink));
  }

  /// Override this to customize creating 'Upload-Metadata'
  String generateMetadata() {
    final meta = Map<String, String>.from(metadata ?? {});

    if (!meta.containsKey("filename")) {
      meta["filename"] = p.basename(filename);
    }

    return meta.entries
        .map((entry) =>
            entry.key + " " + base64.encode(utf8.encode(entry.value)))
        .join(",");
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
