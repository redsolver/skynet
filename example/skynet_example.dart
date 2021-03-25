// @dart=2.9

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:skynet/skynet.dart';

void main() async {
  SkynetConfig.host = 'siasky.net';

  final user = SkynetUser.fromSeedAsync(
    hex.decode(
        '788dddf5232807611557a3dc0fa5f34012c2650526ba91d55411a2b04ba56164'),
  );
  await user.init();

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
