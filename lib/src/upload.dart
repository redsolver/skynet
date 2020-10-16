import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'file.dart';
import 'config.dart';

Future<String> uploadFile(SkyFile file) async {
  var uri = Uri.https(SkynetConfig.host, '/skynet/skyfile');

  var request = http.MultipartRequest("POST", uri);
  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    file.content,
    filename: file.filename,
    contentType: MediaType.parse(file.type),
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
