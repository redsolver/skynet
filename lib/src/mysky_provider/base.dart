import 'dart:typed_data';

import 'package:skynet/src/client.dart';
import 'package:skynet/src/data_with_revision.dart';
import 'package:skynet/src/registry_classes.dart';

abstract class MySkyProvider {
  SkynetClient client;
  MySkyProvider(this.client);

  Future<void> load(String dataDomain, {Map options = const {}});
  Future<bool> checkLogin();
  Future<void> logout();
  Future<bool> requestLoginAccess();
  Future<String> userId();
  Future<Uint8List> signRegistryEntry(RegistryEntry entry, String path);
  Future<Uint8List> signEncryptedRegistryEntry(
      RegistryEntry entry, String path);
  Future<String> getEncryptedFileSeed(String path, bool isDirectory);

  Future<bool> setJSON(
    String path,
    dynamic data,
    int revision, {
    String filename = 'skynet-dart-sdk.json',
  });

  Future<DataWithRevision<dynamic>> getJSON(
    String path, {
    String filename = 'skynet-dart-sdk.json',
  });

  Future<bool> setJSONEncrypted(
    String path,
    dynamic data,
    int revision,
  );

  Future<DataWithRevision<dynamic>> getJSONEncrypted(
    String path, {
    String filename = 'skynet-dart-sdk.json',
    String? userID,
    String? pathSeed,
  });

  Future<bool> setRawDataEncrypted(
    String path,
    Uint8List data,
    int revision, {
    String? customEncryptedFileSeed,
  });

  Future<DataWithRevision<Uint8List?>> getRawDataEncrypted(
    String path, {
    String filename = 'skynet-dart-sdk.json',
    String? userID,
    String? pathSeed,
  });
}
