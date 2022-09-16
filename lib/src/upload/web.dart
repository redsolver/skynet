import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:skynet/skynet.dart';

Future<String?> uploadFileWithStreamWeb(
  SkyFile file,
  int length,
  Stream<Uint8List> readStream, {
  required SkynetClient skynetClient,
}) async {
  var uri = Uri.parse(
    '${skynetClient.portalProtocol}://${skynetClient.portalHost}/skynet/skyfile',
  );

  final completer = Completer<int>();

  final request = HttpRequest();
  request.withCredentials = skynetClient.withCredentials;
  request.open('POST', uri.toString());

// upload progress event
  request.upload.addEventListener('progress', (e) {
    final event = (e as ProgressEvent);
    final progress = (event.loaded! / event.total!);
    print('uploadProgress $progress');
  });

  if (skynetClient.headers != null) {
    for (final entry in skynetClient.headers!.entries) {
      request.setRequestHeader(entry.key, entry.value);
    }
  }
  //final mimeType = lookupMimeType(file.filename ?? '');

  request.setRequestHeader(
    'content-type',
    'application/x-www-form-urlencoded; charset=UTF-8',
  );

// AJAX request finished event
  request.addEventListener('load', (e) {
    completer.complete(request.status);
    /* // HTTP status message
	console.log(request.status);

	// request.response will hold the response from the server
	console.log(request.response); */
  });

// send POST request to server side script
  final formData = new FormData();
  // formData.append('file', document.querySelector('#file-input').files[0]);
  request.send(formData);

  final statusCode = await completer.future;

  /*  var stream = http.ByteStream(readStream);

  var request = http.MultipartRequest("POST", uri);

  request.headers.addAll(skynetClient.headers ?? {});


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

  if (resData['skylink'] == null) throw Exception('Skynet Upload Fail'); */
  print(request.responseText);

  return request.responseText;
}
