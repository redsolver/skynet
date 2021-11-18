import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:skynet/skynet.dart';
import 'package:skynet/src/utils/js_js.dart';

abstract class DACLibrary {
  final String dacDomain;
  DACLibrary(this.dacDomain);

  late final SkynetClient skynetClient;
  late String iframeUrl;

  void init(SkynetClient client) {
    skynetClient = client;
  }

  Future<void> load() async {
    iframeUrl = skynetClient.resolveSkylink(
        /* options['debug'] == true */ /*  true // TODO
            ? */
        'sia://${dacDomain}?debug=true' /* : 'sia://skynet-mysky.hns' */)!;
    final src =
        '<iframe src="$iframeUrl" name="$iframeUrl" style="display: none;"></iframe>';

    document.querySelector('body')!.appendHtml(
          src,
          validator: _TrustedNodeValidator(),
        );

    _iframe = document.getElementsByName(iframeUrl)[0] as IFrameElement;

    final iframeHost = Uri.parse(iframeUrl).host;

    // print(iframe);
    final handshakeCompleter = Completer<bool>();
    window.addEventListener('message', (event) {
      final e = event as MessageEvent;

      print('onmessage $e');

      final origin = Uri.parse(e.origin);
      if (origin.host != iframeHost) return;

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
        if (_reqs.containsKey(requestId)) {
          _reqs[requestId]!.complete(e.data);
        }
      } else if (action == 'callback') {
        final callbackId = e.data['callbackId'];
        _callbacks[callbackId]!(e.data['args'][0]);
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

      _iframe.contentWindow!.postMessage(
        data,
        '*',
      );
      await Future.delayed(Duration(milliseconds: 200));
    }
    print('handshake completed');
    await call('init');
  }

  int _requestIdCounter = 0;
  int _callbackIdCounter = 0;

  final Map<int, Completer<dynamic>> _reqs = {};
  final Map<int, Function> _callbacks = {};

  Map passCallback(Function callback) {
    _callbackIdCounter++;
    final id = _callbackIdCounter;
    _callbacks[id] = callback;
    return {'type': '@post-me', 'proxy': 'callback', 'callbackId': id};
  }

  late IFrameElement _iframe;

  final sessionId = 101;

  Future<dynamic> call(
    String methodName, [
    dynamic args = const [],
    bool useEval = false,
    Map<String, String>? evalVariables,
  ]) async {
    _requestIdCounter++;
    final requestId = _requestIdCounter;
    final completer = Completer();
    _reqs[requestId] = completer;
    final data = {
      'action': "call",
      'methodName': methodName,
      'requestId': requestId,
      'sessionId': sessionId,
      'args': args,
      'type': "@post-me",
    };

    print('Dart->${iframeUrl}: $data');

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
      _iframe.contentWindow!.postMessage(
        data,
        '*',
      );
    }
    print('test');

    final res = await completer.future;
    print(res);
    if (res['error'] != null) {
      throw '${res['error']['name']}: ${res['error']['message']}';
    }
    return res['result'];
  }
}

/// A [NodeValidator] which allows everything.
class _TrustedNodeValidator implements NodeValidator {
  bool allowsElement(Element element) => true;
  bool allowsAttribute(element, attributeName, value) => true;
}
