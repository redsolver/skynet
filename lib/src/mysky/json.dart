import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:pinenacl/api.dart';
import 'package:skynet/skynet.dart';
import 'package:skynet/src/mysky/tweak.dart';
import 'package:skynet/src/registry.dart';
import 'package:skynet/src/skydb.dart';

Future<dynamic?> getJSON(String userId, String path) async {
  // final path = 'snew.hns/asdf';
  try {
    final result = await getSkyFile(userId, path);
    final data = json.decode(utf8.decode(result.data.content));
    // print('getJSON $data');
    if (data.containsKey('_data')) {
      // print('[debug] [getJSON] $userId/$path: $data');
      return data['_data'];
    }
    return data;
  } catch (e) {
    print(e);
    return null;
  }
}

class DataWithRevision<T> {
  final T data;
  final int revision;
  DataWithRevision(this.data, this.revision);
}

Future<DataWithRevision<dynamic?>> getJSONWithRevision(
    String userId, String path) async {
  try {
    final result = await getSkyFile(userId, path);

    final data = json.decode(utf8.decode(result.data.content));
    // print('getJSON $data');
    if (data.containsKey('_data')) {
      // print('[debug] [getJSON] $userId/$path: $data');
      return DataWithRevision(data['_data'], result.revision);
    }
    return DataWithRevision(data, result.revision);
  } catch (e) {
    print(e);
    return DataWithRevision(null, 0);
  }
}

Future<bool> setJSON(SkynetUser skynetUser, String path, Map data, int revision,
    {String filename = 'skynet-dart-sdk.json'}) async {
  /*  try { */
  final datakey = deriveDiscoverableTweak(path);

  // upload the file to acquire its skylink
  final skylink = await (uploadFile(
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
    data: utf8.encode(skylink) as Uint8List,
    revision: revision, //(existing?.entry.revision ?? 0) + 1,
  );

  rv.hashedDatakey = datakey;

  // sign it
  final sig = await skynetUser.sign(rv.hash());

  final srv = SignedRegistryEntry(signature: sig, entry: rv);

  //print(srv.toJson());

  // update the registry
  final updated = await setEntry(
    skynetUser,
    '',
    srv,
    hashedDatakey: hex.encode(datakey),
  );

  return updated;
}

// TODO setJson

Future<DataWithRevision<SkyFile>> getSkyFile(String userId, String path) async {
  // final path = 'snew.hns/asdf';
  final datakey = deriveDiscoverableTweak(path);

  final res = await getFileWithRevision(
    SkynetUser.fromId(userId),
    '',
    hashedDatakey: hex.encode(datakey),
  );
  return res;
}
