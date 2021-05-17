import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'crypto.dart';
import 'file.dart';
import 'mysky/tweak.dart';
import 'registry_classes.dart';
import 'client.dart';
import 'user.dart';

/*
1: Subscribe to entry with key
2: Write to a key
3: Receive entry update
4: Cancel subscription
X9: Add FileID to server cache
11: Notify
 */

class ConnectionState {
  ConnectionStateType type = ConnectionStateType.none;
}

enum ConnectionStateType {
  none,
  disconnected,
  connected,
}

class SkyDBoverWS {
  SkyDBoverWS(this.skynetClient);

  SkynetClient skynetClient;

  late WebSocketChannel channel;
  String endpoint = 'wss://fra1.skydb.solver.cloud';

  Function onConnectionStateChange = () {};

  ConnectionState connectionState = ConnectionState();

  void connect() {
    print('[SkyDBoverWS] connectint to ${endpoint} ...');

    try {
      channel = WebSocketChannel.connect(
        Uri.parse('$endpoint/skynet/registry/ws'),
      );
    } catch (e) {
      connectionState.type = ConnectionStateType.disconnected;
      onConnectionStateChange();
      _retry();
      return;
    }

    connectionState.type = ConnectionStateType.connected;
    onConnectionStateChange();

    if (streams.isNotEmpty) {
      for (final k in streams.keys) {
        final key = Uint8List.fromList(k.codeUnits);

/*         _send([
          9,
          ...utf8.encode(json.encode(
            fileIdCache[String.fromCharCodes(key.sublist(32))].toJson(),
          ))
        ]); */

        _send([
          1,
          ...key,
        ]);
      }
    }

    channel.stream.listen((message) {
      final int? op = message[0];

      Uint8List? data = message.sublist(1);

      if (op == 3) {
        final key = String.fromCharCodes(data!.sublist(0, 64));
        final value = data.sublist(64);

        final srv = SignedRegistryEntry.fromBytes(value,
            publicKeyBytes: data.sublist(0, 32));

        revisionCache[key] = srv.entry.revision;

        streams[key]!.add(srv); // TODO Verify signature
      }

      // channel.sink.close(status.goingAway);
    }, onDone: () {
      connectionState.type = ConnectionStateType.disconnected;
      onConnectionStateChange();
      _retry();
    });
  }

  void _retry() async {
    print('Lost connection. Retrying in 1 second...');

    await Future.delayed(Duration(seconds: 1));
    connect();
  }

  Map<String, StreamController<SignedRegistryEntry>> streams = {};

  Map<String, int> revisionCache = {};
/*   Map<String, FileID> fileIdCache = {}; */

  void _send(List<int> data) {
    channel.sink.add(Uint8List.fromList(data));
  }

  bool isSubscribed(
    SkynetUser user,
    String path,
  ) {
    final key = Uint8List.fromList([
      ...user.publicKey.bytes,
      ...deriveDiscoverableTweak(path),
    ]);

    return streams.containsKey(String.fromCharCodes(key));
  }

  Stream<SignedRegistryEntry> subscribe(
    SkynetUser user,
    String datakey, {
    String? path,
  }) {
    final key = Uint8List.fromList([
      ...user.publicKey.bytes,
      ...(path != null ? deriveDiscoverableTweak(path) : hashDatakey(datakey))
    ]);

    final sc = StreamController<SignedRegistryEntry>.broadcast();

    streams[String.fromCharCodes(key)] = sc;

    // fileIdCache[String.fromCharCodes(key.sublist(32))] = fileID;

    _send([
      1,
      ...key,
    ]);

    return sc.stream;
  }

  void cancelSub(
    SkynetUser user,
    String datakey, {
    String? path,
  }) {
    final key = Uint8List.fromList([
      ...user.publicKey.bytes,
      ...(path != null ? deriveDiscoverableTweak(path) : hashDatakey(datakey))
    ]);

    _send([
      4,
      ...key,
    ]);

    final k = String.fromCharCodes(key);

    streams[k]!.close();

    streams.remove(k);
  }

  Future<void> update(SkynetUser user, String datakey, String? value,
      {int? revision, Uint8List? altValue, String? path}) async {
    final key = Uint8List.fromList([
      ...user.publicKey.bytes,
      ...(path != null ? deriveDiscoverableTweak(path) : hashDatakey(datakey))
    ]);
    final keyStr = String.fromCharCodes(key);

    if (revision == null) {
      if (!streams.containsKey(keyStr))
        throw Exception(
            'You need to subscribe to a SkyDB entry before updating it! (datakey: $datakey)');
    }

    // build the registry value
    final rv = RegistryEntry(
      //tweak: fileID.hash(),
      data: altValue ?? utf8.encode(value!) as Uint8List,
      revision: revision ?? ((revisionCache[keyStr] ?? 0) + 1),
    );

    if (path != null) {
      rv.hashedDatakey = deriveDiscoverableTweak(path);
    } else {
      rv.datakey = datakey;
    }

    // sign it
    final sig = await user.sign(rv.hash());

    final srv = SignedRegistryEntry(signature: sig, entry: rv);

    _send([2, ...key, ...srv.toBytes()]);
  }

  void notify(SkynetUser skynetUser, String path) {
    final key = Uint8List.fromList([
      ...skynetUser.publicKey.bytes,
      ...deriveDiscoverableTweak(path),
    ]);

    _send([11, ...key]);
  }

  Future<bool> setFile(SkynetUser user, String datakey, SkyFile file,
      {int? revision}) async {
    // upload the file to acquire its skylink
    final skylink = await skynetClient.upload.uploadFile(file);
    await update(user, datakey, skylink, revision: revision);
    return true;
  }

  Future<bool> setJSON(
      SkynetUser skynetUser, String path, dynamic data, int revision,
      {String filename = 'skynet-dart-sdk.json'}) async {
    // final datakey = deriveDiscoverableTweak(path);

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

    await update(skynetUser, '', skylink, revision: revision, path: path);

    return true;
  }

  Future<SkyFile> downloadFileFromRegistryEntry(SignedRegistryEntry sre) async {
    final skylink = utf8.decode(sre.entry.data);

    final res = await http.get(Uri.https(skynetClient.portalHost, '$skylink'));

    // print('downloadFileFromRegistryEntry HTTP ${res.statusCode}');

    // final metadata = json.decode(res.headers['skynet-file-metadata']!);

    // print('downloadFileFromRegistryEntry metadata ${metadata}');

    final file = SkyFile(
        content: res.bodyBytes,
        filename: null, //metadata['filename'],
        type: res.headers['content-type']);

    return file;
  }
}
