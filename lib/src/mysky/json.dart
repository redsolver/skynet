import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:pinenacl/api.dart';
import 'package:skynet/src/client.dart';
import 'package:skynet/src/crypto.dart';
import 'package:skynet/src/data_with_revision.dart';
import 'package:skynet/src/file.dart';
import 'package:skynet/src/user.dart';
import 'package:skynet/src/registry_classes.dart';
import 'tweak.dart';

// import 'package:skynet/src/registry.dart';
// import 'package:skynet/src/skydb.dart';
// import 'package:skynet/src/upload.dart';

Future<dynamic?> getJSON(
  String userId,
  String path, {
  required SkynetClient skynetClient,
}) async {
  // final path = 'snew.hns/asdf';
  try {
    final result = await getSkyFile(
      userId,
      path,
      skynetClient: skynetClient,
    );
    final data = json.decode(utf8.decode(result.data.content));
    if (data.containsKey('_data')) {
      return data['_data'];
    }
    return data;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<DataWithRevision<dynamic?>> getJSONWithRevision(
  String userId,
  String path, {
  required SkynetClient skynetClient,
}) async {
  try {
    final result = await getSkyFile(
      userId,
      path,
      skynetClient: skynetClient,
    );

    final data = json.decode(utf8.decode(result.data.content));

    if (data.containsKey('_data')) {
      return DataWithRevision(data['_data'], result.revision);
    }
    return DataWithRevision(data, result.revision);
  } catch (e) {
    print(e);
    return DataWithRevision(null, 0);
  }
}

Future<bool> setJSON(
  SkynetUser skynetUser,
  String path,
  dynamic data,
  int revision, {
  String filename = 'skynet-dart-sdk.json',
  required SkynetClient skynetClient,
}) async {
  /*  try { */
  final datakey = deriveDiscoverableTweak(path);

  // upload the file to acquire its skylink
  final skylink = await (skynetClient.upload.uploadFile(
    SkyFile(
      content: Uint8List.fromList(utf8.encode(json.encode({
        '_data': data,
        '_v': 2,
      }))),
      filename: filename,
      type: 'application/json',
    ),
  ));

  if (skylink == null) {
    throw 'Upload failed';
  }

  /*  SignedRegistryEntry? existing;

  try {
    // fetch the current value to find out the revision
    final res = await getEntry(
      user,
      datakey,
      hashedDatakey: hashedDatakey,
    );

    existing = res;
  } catch (e) {
    existing = null;
  } */

  // TODO: we could (/should?) verify here

  // build the registry value
  final rv = RegistryEntry(
    datakey: null,
    data: convertSkylinkToUint8List(skylink),
    revision: revision, //(existing?.entry.revision ?? 0) + 1,
  );

  rv.hashedDatakey = datakey;

  // sign it
  final sig = await skynetUser.sign(rv.hash());

  final srv = SignedRegistryEntry(signature: sig, entry: rv);

  // update the registry
  final updated = await skynetClient.registry.setEntryRaw(
    skynetUser,
    '',
    srv,
    hashedDatakey: hex.encode(datakey),
  );

  return updated;
}

Future<DataWithRevision<SkyFile>> getSkyFile(
  String userId,
  String path, {
  required SkynetClient skynetClient,
}) async {
  // final path = 'snew.hns/asdf';
  final datakey = deriveDiscoverableTweak(path);

  final res = await skynetClient.skydb.getFileWithRevision(
    SkynetUser.fromId(userId),
    '',
    hashedDatakey: hex.encode(datakey),
  );
  return res;
}
