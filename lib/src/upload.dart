import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:skynet/src/client.dart';
import 'package:http/http.dart' as http;
import 'package:cross_file_dart/cross_file_dart.dart' show XFileDart;
import 'package:skynet/src/skynet_tus_client.dart';
import 'package:tus_client/tus_client.dart';

import 'file.dart';

Future<String?> uploadFile(
  SkyFile file, {
  required SkynetClient skynetClient,
}) async {
  var uri = Uri.https(skynetClient.portalHost, '/skynet/skyfile');

  var request = http.MultipartRequest('POST', uri);

  request.headers.addAll(skynetClient.headers ?? {});

  final mimeType = file.type ?? lookupMimeType(file.filename ?? '');

  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    file.content,
    filename: file.filename,
    contentType: mimeType == null ? null : MediaType.parse(mimeType),
  );

  request.files.add(multipartFile);
  final response = await skynetClient.httpClient.send(request);

  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}');
  }

  final res = await response.stream.transform(utf8.decoder).join();

  final resData = json.decode(res);

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

  return resData['skylink'];
}

Future<String?> uploadFileWithStream(
  SkyFile file,
  int length,
  Stream<List<int>> readStream, {
  required SkynetClient skynetClient,
}) async {
  var uri = Uri.https(skynetClient.portalHost, '/skynet/skyfile');

  var stream = http.ByteStream(readStream);

  var request = http.MultipartRequest("POST", uri);

  request.headers.addAll(skynetClient.headers ?? {});

  final mimeType = lookupMimeType(file.filename ?? '');

  var multipartFile = http.MultipartFile(
    'file',
    stream,
    length,
    filename: file.filename,
    contentType: mimeType == null ? null : MediaType.parse(mimeType),
  );

  request.files.add(multipartFile);
  final response = await skynetClient.httpClient.send(request);

  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}');
  }

  final res = await response.stream.transform(utf8.decoder).join();

  final resData = json.decode(res);

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

  return resData['skylink'];
}

/**
  * The tus chunk size is (4MiB - encryptionOverhead) * dataPieces, set in skyd.
 */
const TUS_CHUNK_SIZE = (1 << 22) * 10; // ~ 41 MB

Future<String?> uploadLargeFile(
  XFileDart file, {
  Function(double)? onProgress,
  String? filename,
  /* Function()? onComplete, */
  required SkynetClient skynetClient,
}) async {
  final tusClient = SkynetTusClient(
    Uri.https(skynetClient.portalHost, '/skynet/tus'),
    file,
    skynetClient: skynetClient,
    store: TusMemoryStore(),
    maxChunkSize: TUS_CHUNK_SIZE,
    metadata: filename == null ? {} : {'filename': filename},
    headers: skynetClient.headers,
    // headers: skynetClient.httpClient.
  );
  final res = await tusClient.upload(
    onProgress: onProgress,
  );

  return res;
}

Future<String?> uploadDirectory(
  Map<String, Stream<List<int>>> fileStreams,
  Map<String, int> lengths,
  String fname, {
  required SkynetClient skynetClient,
}) async {
  var uri = Uri.https(skynetClient.portalHost, '/skynet/skyfile', {
    'filename': fname,
  });

  var request = http.MultipartRequest("POST", uri);

  request.headers.addAll(skynetClient.headers ?? {});

  for (final filename in fileStreams.keys) {
    var stream = http.ByteStream(fileStreams[filename]!);

    final mimeType = lookupMimeType(filename);

    var multipartFile = http.MultipartFile(
      'file',
      stream,
      lengths[filename]!,
      filename: filename,
      contentType: mimeType == null ? null : MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);
  }

  final response = await skynetClient.httpClient.send(request);

  if (response.statusCode != 200) {
    print(utf8.decode(await response.stream.toBytes()));
    throw Exception('HTTP ${response.statusCode}');
  }

  final res = await response.stream.transform(utf8.decoder).join();

  final resData = json.decode(res);

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

  return resData['skylink'];
}
