# Skynet SDK for Dart

Use Sia Skynet and SkyDB in your Dart and Flutter projects (Decentralized CDN and database)

This package allows you to use the decentralized SkyDB (https://blog.sia.tech/skydb-a-mutable-database-for-the-decentralized-web-7170beeaa985) and upload files to Skynet.

It also supports Dart-to-JS bindings for MySky and popular DACs (Profile DAC, Feed DAC and Social DAC).

## Breaking changes in version 4.0.0

You now have to use the `SkynetClient()` instance for all operations. See the example below for details or contact me on Discord if you need help migrating your project.

## Install

```yaml
dependencies:
  skynet:
    git: https://github.com/redsolver/skynet.git
```

## Usage

```dart
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
```
