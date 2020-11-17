import 'dart:io';

import 'package:skynet/skynet.dart';

void main() async {
  final fileStreams = <String, Stream<List<int>>>{};
  final lengths = <String, int>{};

  for (final file in [File('README.md'), File('CHANGELOG.md')]) {
    final filename = file.path;
    lengths[filename] = file.lengthSync();
    fileStreams[filename] = file.openRead();
  }

  final res = await uploadDirectory(fileStreams, lengths, 'test');

  print(res);
}
