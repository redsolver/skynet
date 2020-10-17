# Skynet SDK for Dart

Use Sia Skynet and SkyDB in your Dart and Flutter projects (Decentralized CDN and database)

This package allows you to use the decentralized SkyDB (https://blog.sia.tech/skydb-a-mutable-database-for-the-decentralized-web-7170beeaa985) and upload files to Skynet.

## Install

```yaml
dependencies:
  skynet: ^1.0.3
```

## Usage

```dart
import 'dart:convert';
import 'package:skynet/skynet.dart';

void main() async {
  SkynetConfig.host = 'siasky.net';

  final user = User('username', 'password');

  print(user.id); // Public User ID

  final fileID = FileID(
    applicationID: 'note-to-self', // ID of your application
    fileType: FileType.PublicUnencrypted,
    filename: 'note.txt', // Filename of the data you want to store
  );

  final currentFile = await getFile(user, fileID);
  print(currentFile.asString);

  final res = await setFile(
    user,
    fileID,
    SkyFile(
      content: utf8.encode('Hello, world!'), // The content you want to store
      filename: fileID.filename,
      type:
          'text/plain', // Content type (Other examples: application/json or image/png)
    ),
  );
  print(res);

  final updatedFile = await getFile(user, fileID);
  print(updatedFile.asString);
}
```
