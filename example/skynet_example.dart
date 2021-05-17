import 'dart:convert';
import 'dart:typed_data';

import 'package:skynet/skynet.dart';

import 'package:convert/convert.dart';

void main() async {
  final skynetClient = SkynetClient('siasky.net');

  final user = SkynetUser.fromSeedAsync(
    hex.decode(
        '788dddf5232807611557a3dc0fa5f34012c2650526ba91d55411a2b04ba56164'),
  );
  await user.init();

  print(user.id); // Public User ID

  final datakey = 'my-awesome-datakey';

  try {
    final currentFile = await skynetClient.skydb.getFile(user, datakey);
    print(currentFile.asString);
  } catch (e) {
    // ! getFile throws an Exception if no data is found
  }

  final success = await skynetClient.skydb.setFile(
    user,
    datakey,
    SkyFile(
      content: Uint8List.fromList(
          utf8.encode('Hello, world!')), // The content you want to store
      filename: 'note.txt',
      type:
          'text/plain', // Content type (Other examples: application/json or image/png)
    ),
  );
  print(success); // Is true when the operation was successful

  final updatedFile = await skynetClient.skydb.getFile(user, datakey);
  print(updatedFile.asString);
}
