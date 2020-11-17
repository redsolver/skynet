import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:cryptography/cryptography.dart';
import 'package:skynet/skynet.dart';
// import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

/*
1: Subscribe to entry with key
2: Write to a key
3: Receive entry update
4: Cancel subscription
X9: Add FileID to server cache
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
  WebSocketChannel channel;
  String endpoint = 'wss://fra1.skydb.solver.cloud';

  Function onConnectionStateChange = () {};

  ConnectionState connectionState = ConnectionState();

  void connect() {
    print('connect...');

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
      /*   print(message.runtimeType);
      print(message); */

      //  print(message);

      final int op = message[0];

      Uint8List data = message.sublist(1);

      if (op == 3) {
        //   print('Received value');
        final key = String.fromCharCodes(data.sublist(0, 64));
        final value = data.sublist(64);

        final srv = SignedRegistryEntry.fromBytes(value,
            publicKeyBytes: data.sublist(0, 32));

        // srv.setPublicKey(data.sublist(0, 32));

        // print(revisionCache[key]);

        revisionCache[key] = srv.entry.revision;
        // print(streams[key]);

        streams[key].add(srv); // TODO Verify signature
      }

      // channel.sink.close(status.goingAway);
    }, onDone: () {
      connectionState.type = ConnectionStateType.disconnected;
      onConnectionStateChange();
      _retry();
    });
  }

  void _retry() async {
    print('Lost connection. Retrying in 3 seconds...');

    await Future.delayed(Duration(seconds: 3));
    connect();
  }

  Map<String, StreamController<SignedRegistryEntry>> streams = {};

  Map<String, int> revisionCache = {};
/*   Map<String, FileID> fileIdCache = {}; */

  void _send(List<int> data) {
    channel.sink.add(Uint8List.fromList(data));
  }

  Stream<SignedRegistryEntry> subscribe(
    SkynetUser user,
    String datakey,
  ) {
    final key =
        Uint8List.fromList([...user.publicKey.bytes, ...hashDatakey(datakey)]);

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
    String datakey,
  ) {
    final key =
        Uint8List.fromList([...user.publicKey.bytes, ...hashDatakey(datakey)]);

    _send([
      4,
      ...key,
    ]);

    final k = String.fromCharCodes(key);

    streams[k].close();

    streams.remove(k);
  }

  Future<void> update(SkynetUser user, String datakey, String value,
      {int revision, Uint8List altValue}) async {
    final key =
        Uint8List.fromList([...user.publicKey.bytes, ...hashDatakey(datakey)]);
    final keyStr = String.fromCharCodes(key);

    if (revision == null) {
      if (!streams.containsKey(keyStr))
        throw Exception(
            'You need to subscribe to a SkyDB entry before updating it!');
    }

    // print('update to $value');

    // build the registry value
    final rv = RegistryEntry(
      //tweak: fileID.hash(),
      data: altValue ?? utf8.encode(value),
      revision: revision ?? ((revisionCache[keyStr] ?? 0) + 1),
    );
    rv.datakey = datakey;

    // sign it
    final sig = await user.sign(rv.hash());

    final srv = SignedRegistryEntry(signature: sig, entry: rv);

    _send([2, ...key, ...srv.toBytes()]);
  }

  Future<bool> setFile(SkynetUser user, String datakey, SkyFile file,
      {int revision}) async {
    // upload the file to acquire its skylink
    final skylink = await uploadFile(file);
    await update(user, datakey, skylink, revision: revision);
    return true;
  }

  Future<SkyFile> downloadFileFromRegistryEntry(SignedRegistryEntry sre) async {
    final skylink = utf8.decode(sre.entry.data);

    final res = await http.get(Uri.https(SkynetConfig.host, '$skylink'));

    final metadata = json.decode(res.headers['skynet-file-metadata']);

    final file = SkyFile(
        content: res.bodyBytes,
        filename: metadata['filename'],
        type: res.headers['content-type']);

    return file;
  }
}
