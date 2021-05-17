import 'package:skynet/skynet.dart';
import 'dart:io';

void main() async {
  final skynetClient = SkynetClient('siasky.net');

  final fileStreams = <String, Stream<List<int>>>{};
  final lengths = <String, int>{};

  for (final file in [
    File('README.md'),
    File('CHANGELOG.md'),
    File('lib/skynet.dart'),
  ]) {
    final filename = file.path;
    lengths[filename] = file.lengthSync();
    fileStreams[filename] = file.openRead();
  }

  final skylink = await skynetClient.upload
      .uploadDirectory(fileStreams, lengths, 'example-directory');

  print(skylink);
}
