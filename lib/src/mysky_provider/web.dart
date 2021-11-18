import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:skynet/skynet.dart';
import 'package:skynet/src/mysky/permission.dart';
import 'package:skynet/src/mysky/utils.dart';
import 'package:skynet/src/mysky_provider/base.dart';
export 'package:skynet/src/mysky/permission.dart';
import 'package:skynet/src/registry_classes.dart';
import '../mysky/json.dart' as file_impl;
import '../mysky/io.dart' as mysky_io_impl;
import '../utils/js_js.dart';

const mySkyUiTitle = "MySky UI";
const mySkyUiW = 640;
const mySkyUiH = 750;

class WebMySkyProvider extends MySkyProvider {
  final SkynetClient client;

  final Map<int, Completer<dynamic>> reqs = {};

  WebMySkyProvider(this.client) : super(client);

  late IFrameElement iframe;

  final sessionId = 100;
  late String iframeUrl;

  Future<void> load(String dataDomain, {Map options = const {}}) async {
    final hostDomain = client.extractDomain(window.location.hostname!);

    if (dataDomain != null) {
      final perm1 = Permission(
        hostDomain,
        dataDomain,
        PermCategory.Discoverable,
        PermType.Write,
      );
      final perm2 = Permission(
        hostDomain,
        dataDomain,
        PermCategory.Hidden,
        PermType.Read,
      );
      final perm3 = Permission(
        hostDomain,
        dataDomain,
        PermCategory.Hidden,
        PermType.Write,
      );
      pendingPermissions.addAll([perm1, perm2, perm3]);
    }

    iframeUrl =
        client.resolveSkylink(/* options['debug'] == true */ true // TODO
            ? 'sia://skynet-mysky.hns?debug=true'
            : 'sia://skynet-mysky.hns')!;

    final mySkyHost = 'skynet-mysky.hns.${client.portalHost}';

    print(iframeUrl);

    // https://skynet-mysky.hns.siasky.net?debug=true

    final src =
        '<iframe src="$iframeUrl" name="$iframeUrl" style="display: none;"></iframe>';

    document.querySelector('body')!.appendHtml(
          src,
          validator: _TrustedNodeValidator(),
        );

    iframe = document.getElementsByName(iframeUrl)[0] as IFrameElement;

    print(iframe);
    final handshakeCompleter = Completer<bool>();
    window.addEventListener('message', (event) {
      final e = event as MessageEvent;

      final origin = Uri.parse(e.origin);
      if (origin.host != mySkyHost) return;

      print('> wrapper ${e.data}');

      final type = e.data['type'];
      if (type != '@post-me') return;

      if (sessionId != e.data['sessionId']) {
        return;
      }

      final action = e.data['action'];
      if (action == 'handshake-response') {
        handshakeCompleter.complete(true);
      }

      if (action == 'response') {
        final int requestId = e.data['requestId'];
        if (reqs.containsKey(requestId)) {
          reqs[requestId]!.complete(e.data);
        }
      }
    });

    /* print('iframeElement');
    final iframeElement = getElementsByName(url)[0];
    print('cWindow');
    final cWindow = getProperty(iframeElement, 'contentWindow'); */

    while (!handshakeCompleter.isCompleted) {
      final data = {
        'type': "@post-me",
        'action': "handshake-request",
        'sessionId': sessionId,
      };
      /* print('callMethod');
      callMethod(cWindow, 'postMessage', [data, '*']); */

      iframe.contentWindow!.postMessage(
        data,
        '*',
      );
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  var pendingPermissions = <Permission>[];

  Future<bool> checkLogin() async {
    final array = await call('checkLogin', [
      pendingPermissions.map((e) => e.toJson()).toList(),
    ]);
    // const [seedFound, permissionsResponse]: [boolean, CheckPermissionsResponse] ;
    final bool seedFound = array[0];
    final permissionsResponse = array[1];

    final List grantedPermissions = permissionsResponse['grantedPermissions'];
    final List failedPermissions = permissionsResponse['failedPermissions'];

    final loggedIn = seedFound && failedPermissions.isEmpty;
    handleLogin(loggedIn);
    return loggedIn;
  }

  Future<void> logout() {
    return call('logout');
  }

  Future<bool> requestLoginAccess() async {
    print('requestLoginAccess start');
    WindowBase? uiWindow;
    // Connection uiConnection;
    var seedFound = false;

    final completer = Completer<bool>();

    // Add error listener.
    // final { promise: promiseError, controller: controllerError } = monitorWindowError();

    // eslint-disable-next-line no-async-promise-executor
    final future = ((/* resolve, reject */) async {
      // Make this promise run in the background and reject on window close or any errors.
      /*  promiseError.catch((err: string) => {
        if (err == errorWindowClosed) {
          // Resolve without updating the pending permissions.
          // resolve();
          return;
        }

        reject(err);
      }); */

      try {
        final sessionId = 5;
        // Launch the UI.

        uiWindow = this.launchUI();
        print('uiWindow ready');
        // await Future.delayed(Duration(seconds: 10));
        // const options = this.connector.options;
        final handshakeCompleter = Completer<bool>();
        // window.removeEventListener(type, (event) => null)
        window.addEventListener('message', (event) {
          if (completer.isCompleted) return;
          final e = event as MessageEvent;

          final origin = Uri.parse(e.origin);
          // if (origin.host != mySkyHost) return;

          final type = e.data['type'];
          if (type != '@post-me') return;

          if (sessionId != e.data['sessionId']) {
            return;
          }
          print('>  ui ${e.data}');

          final action = e.data['action'];
          if (action == 'handshake-response') {
            handshakeCompleter.complete(true);
          }

          if (action == 'response') {
            seedFound = e.data['result'][0];
            final permissionsResponse = e.data['result'][1];

            final List grantedPermissions =
                permissionsResponse['grantedPermissions'];
            final List failedPermissions =
                permissionsResponse['failedPermissions'];

            pendingPermissions = failedPermissions
                .map(
                  (e) => Permission.fromJson(e),
                )
                .toList();

            completer.complete(true);
            /* final int requestId = e.data['requestId'];
        if (reqs.containsKey(requestId)) {
          reqs[requestId]!.complete(e.data);
        } */
          } else if (action == 'call') {
            final methodName = e.data['methodName'];

            if (methodName == 'catchError') {
              print('catchError ${e.data['args']}');
              completer.complete(false);
            }
          }
        });

        /* print('iframeElement');
    final iframeElement = getElementsByName(url)[0];
    print('cWindow');
    final cWindow = getProperty(iframeElement, 'contentWindow'); */

        while (!handshakeCompleter.isCompleted) {
          print('send "handshake-request"');
          final data = {
            'type': "@post-me",
            'action': "handshake-request",
            'sessionId': sessionId,
          };
          /* print('callMethod');
      callMethod(cWindow, 'postMessage', [data, '*']); */

          uiWindow!.postMessage(
            data,
            '*',
          );
          await Future.delayed(Duration(milliseconds: 200));
        }
        // await Future.delayed(Duration(milliseconds: 100000));

        final requestId = 1;
        /* final completer = Completer();
    reqs[requestId] = completer; */
        final data = {
          'action': 'call',
          'methodName': 'requestLoginAccess',
          'requestId': requestId,
          'sessionId': sessionId,
          'args': [pendingPermissions.map((e) => e.toJson()).toList()],
          'type': "@post-me",
        };

        print('Dart->MySkyUI: $data');

        uiWindow!.postMessage(
          data,
          '*',
        );

        // Complete handshake with UI window.

        // final uiConnection = await this.connectUi(uiWindow);

        // Send the UI the list of required permissions.

        // seedFound = seedFoundResponse;

        // Save failed permissions.

      } catch (e, st) {
        print(e);
        print(st);
        completer.complete(false);
      }
    })();

/* await future.catchError((e){
print('catchError $e');
}); */
    await completer.future;
    // Close the window.
    if (uiWindow != null && !(uiWindow!.closed ?? true)) {
      uiWindow!.close();
    }

    print('requestLoginAccess done');
    // Close the connection.
    /* if (uiConnection!=null) {
          uiConnection.close();
        } */
    // Clean up the event listeners and promises.
    // controllerError.cleanup();

    final loggedIn = seedFound && pendingPermissions.length == 0;
    // print('loggedIn $loggedIn');
    handleLogin(loggedIn);
    return loggedIn;
  }

  WindowBase launchUI() {
    final mySkyUrl = Uri.parse(iframeUrl);
    final uri = Uri(
      /* fragment: mySkyUrl.fragment, */
      host: mySkyUrl.host,
      path: '/ui.html',
      query: mySkyUrl.query,
      scheme: mySkyUrl.scheme,
    );

    // print('launchUI $uri');

    // const uiUrl = mySkyUrl.toString();

    // Open the window.

    final childWindow =
        popupCenter(uri.toString(), mySkyUiTitle, mySkyUiW, mySkyUiH);
    /* if (!childWindow) {
      throw new Error(`Could not open window at '${uiUrl}'`);
    } */

    return childWindow;
  }

  void handleLogin(bool loggedIn) {
    if (loggedIn) {
      /* TODO for (const dac of this.dacs) {
        dac.onUserLogin();
      } */
    }
  }

  int requestIdCounter = 0;

  Future<dynamic> call(
    String methodName, [
    dynamic args = const [],
    bool useEval = false,
    Map<String, String>? evalVariables,
  ]) async {
    requestIdCounter++;
    final requestId = requestIdCounter;
    final completer = Completer();
    reqs[requestId] = completer;
    final data = {
      'action': "call",
      'methodName': methodName,
      'requestId': requestId,
      'sessionId': sessionId,
      'args': args,
      'type': "@post-me",
    };

    print('Dart->MySky: $data');

    // setValue(data, 'args', args);

    if (useEval) {
      var command =
          'document.getElementsByName("$iframeUrl")[0].contentWindow.postMessage(${json.encode(data)},\'*\')';
      // print('[SDK] $command');

      for (final key in (evalVariables ?? {}).keys) {
        command = command.replaceAll('"$key"', evalVariables![key]!);
      }

      // print('[SDK] $command');
      eval(command);
    } else {
      iframe.contentWindow!.postMessage(
        data,
        '*',
      );
    }

    final res = await completer.future;
    if (res['error'] != null) {
      throw '${res['error']['name']}: ${res['error']['message']}';
    }
    return res['result'];
  }

  Future<String> userId() async {
    return await call('userID');
  }

  Future<Uint8List> signRegistryEntry(RegistryEntry entry, String path) async {
    final data = JSRegistryEntry(
      data: entry.data,
      dataKey: hex.encode(
        entry.hashedDatakey!,
      ),
      revision: JSBigInt(
        entry.revision,
      ),
    );
    final re =
        '{"data":new Uint8Array(${json.encode(entry.data)}),"dataKey":"${hex.encode(
      entry.hashedDatakey!,
    )}","revision":BigInt(${entry.revision})}';

    // print('Dart SDK signRegistryEntry');

    return Uint8List.fromList(await call(
        'signRegistryEntry',
        ['lryakSdSKOOooadvcbIshKBifZbo0B1p', path],
        true,
        {
          'lryakSdSKOOooadvcbIshKBifZbo0B1p': re,
        }));
  }

  Future<Uint8List> signEncryptedRegistryEntry(
      RegistryEntry entry, String path) async {
    /*    final data = JSRegistryEntry(
      data: entry.data,
      dataKey: hex.encode(
        entry.hashedDatakey!,
      ),
      revision: JSBigInt(
        entry.revision,
      ),
    ); */
    final re =
        '{"data":new Uint8Array(${json.encode(entry.data)}),"dataKey":"${hex.encode(
      entry.hashedDatakey!,
    )}","revision":BigInt(${entry.revision})}';

    // print('Dart SDK signEncryptedRegistryEntry');

    return Uint8List.fromList(await call(
        'signEncryptedRegistryEntry',
        ['lryakSdSKOOooadvcbIshKBifZbo0B1p', path],
        true,
        {
          'lryakSdSKOOooadvcbIshKBifZbo0B1p': re,
        }));
  }

  Future<String> getEncryptedFileSeed(String path, bool isDirectory) async {
    // print('getEncryptedFileSeed ${path} ${isDirectory}');
    return await call('getEncryptedFileSeed', [path, isDirectory]);
  }

  Future<bool> setJSON(
    String path,
    dynamic data,
    int revision, {
    String filename = 'skynet-dart-sdk.json',
  }) async {
    final userID = await userId();
    return file_impl.setJSON(SkynetUser.fromId(userID), path, data, revision,
        filename: filename,
        skynetClient: client, signRegistryEntry: (RegistryEntry re) async {
      return await signRegistryEntry(re, path);

      // return List<int>
    });
  }

  Future<DataWithRevision<dynamic>> getJSON(
    String path, {
    String filename = 'skynet-dart-sdk.json',
  }) async {
    final userID = await userId();
    return file_impl.getJSONWithRevision(
      userID,
      path,
      skynetClient: client,
    );
  }

  Future<bool> setJSONEncrypted(
    String path,
    dynamic data,
    int revision,
    // String filename = 'skynet-dart-sdk.json',
  ) async {
    final userID = await userId();
    final pathSeed = await getEncryptedFileSeed(path, false);
    return mysky_io_impl.setEncryptedJSON(
      SkynetUser.fromId(userID),
      path,
      data,
      revision,
      skynetClient: client,
      customPathSeed: pathSeed,
      signEncryptedRegistryEntry: (RegistryEntry re) async {
        return await signEncryptedRegistryEntry(re, path);

        // return List<int>
      },
    );
  }

  // TODO Do some fancy caching where only revision numbers are checked and immutable skylink json contents are cached (global)
  Future<DataWithRevision<dynamic>> getJSONEncrypted(
    String path, {
    String filename = 'skynet-dart-sdk.json',
    String? userID,
    String? pathSeed,
  }) async {
    userID ??= await userId();
    pathSeed ??= await getEncryptedFileSeed(path, false);

    return mysky_io_impl.getJSONEncrypted(
      userID,
      pathSeed,
      skynetClient: client,
    );
  }

  Future<bool> setRawDataEncrypted(
    String path,
    Uint8List data,
    int revision, {
    String? customEncryptedFileSeed,
  }
      // String filename = 'skynet-dart-sdk.json',
      ) async {
    final userID = await userId();
    final pathSeed =
        customEncryptedFileSeed ?? await getEncryptedFileSeed(path, false);
    return mysky_io_impl.setEncryptedRawData(
      SkynetUser.fromId(userID),
      path,
      data,
      revision,
      skynetClient: client,
      customPathSeed: pathSeed,
      signEncryptedRegistryEntry: (RegistryEntry re) async {
        return await signEncryptedRegistryEntry(re, path);
      },
    );
  }

  // TODO Do some fancy caching where only revision numbers are checked and immutable skylink json contents are cached (global)
  Future<DataWithRevision<Uint8List?>> getRawDataEncrypted(
    String path, {
    String filename = 'skynet-dart-sdk.json',
    String? userID,
    String? pathSeed,
  }) async {
    userID ??= await userId();
    pathSeed ??= await getEncryptedFileSeed(path, false);

    return mysky_io_impl.getEncryptedRawData(
      userID,
      pathSeed,
      skynetClient: client,
    );
  }
}

/// A [NodeValidator] which allows everything.
class _TrustedNodeValidator implements NodeValidator {
  bool allowsElement(Element element) => true;
  bool allowsAttribute(element, attributeName, value) => true;
}
