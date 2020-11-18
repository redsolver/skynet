import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'file.dart';
import 'config.dart';

Future<String> uploadFile(SkyFile file) async {
  var uri = Uri.https(SkynetConfig.host, '/skynet/skyfile');

  var request = http.MultipartRequest("POST", uri);
  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    file.content,
    filename: file.filename,
    // contentType: MediaType.parse(file.type),
  );

  request.files.add(multipartFile);
  var response = await request.send();

  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}');
  }

  final res = await response.stream.transform(utf8.decoder).join();

  final resData = json.decode(res);

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

  return resData['skylink'];
}

Future<String> uploadFileWithStream(
    SkyFile file, int length, Stream<List<int>> readStream) async {
  var uri = Uri.https(SkynetConfig.host, '/skynet/skyfile');

  var stream = http.ByteStream(readStream);

  var request = http.MultipartRequest("POST", uri);

  final mimeType = lookupMimeType(file.filename ?? '');

  var multipartFile = http.MultipartFile(
    'file',
    stream,
    length,
    filename: file.filename,
    contentType: mimeType == null ? null : MediaType.parse(mimeType),
  );

  request.files.add(multipartFile);
  var response = await request.send();

  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}');
  }

  final res = await response.stream.transform(utf8.decoder).join();

  final resData = json.decode(res);

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

  return resData['skylink'];
}

Future<String> uploadDirectory(
  Map<String, Stream<List<int>>> fileStreams,
  Map<String, int> lengths,
  String fname,
) async {
  var uri = Uri.https(SkynetConfig.host, '/skynet/skyfile', {
    'filename': fname,
  });

  var request = http.MultipartRequest("POST", uri);

  for (final filename in fileStreams.keys) {
    var stream = http.ByteStream(fileStreams[filename]);

    final mimeType = lookupMimeType(filename);

    var multipartFile = http.MultipartFile(
      'file',
      stream,
      lengths[filename],
      filename: filename,
      contentType: mimeType == null ? null : MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);
  }

  var response = await request.send();

  if (response.statusCode != 200) {
    print(utf8.decode(await response.stream.toBytes()));
    throw Exception('HTTP ${response.statusCode}');
  }

  final res = await response.stream.transform(utf8.decoder).join();

  final resData = json.decode(res);

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

  return resData['skylink'];
}
