import 'dart:convert';
import 'package:skynet/skynet.dart';

void main() async {
  SkynetConfig.host = 'siasky.net';

  final user = SkynetUser('username', 'password');

  print(user.id); // Public User ID

  final datakey = 'my-awesome-datakey';

  final currentFile = await getFile(user, datakey);
  print(currentFile.asString);

  final res = await setFile(
    user,
    datakey,
    SkyFile(
      content: utf8.encode('Hello, world!'), // The content you want to store
      filename: 'note.txt',
      type:
          'text/plain', // Content type (Other examples: application/json or image/png)
    ),
  );
  print(res);

  final updatedFile = await getFile(user, datakey);
  print(updatedFile.asString);
}
