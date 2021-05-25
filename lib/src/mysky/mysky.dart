import 'package:skynet/src/client.dart';
import 'package:skynet/src/dacs/dac.dart';

import 'package:js/js_util.dart';
import 'package:skynet/src/utils/js.dart';

import 'mysky_js.dart';

class MySky {
  late JSMySky _jsMySky;

  Future<void> load(
    String skappDomain, {
    required SkynetClient skynetClient,
  }) async {
    // skynetClient ??= SkynetClient();

    final client = JSSkynetClient('https://${skynetClient.portalHost}');

    _jsMySky = await promiseToFuture<JSMySky>(
      client.loadMySky(
        skappDomain,
        /* CustomConnectorOptions(
          debug: true,
        ), */
      ),
    );
  }

  Future<void> loadDACs(List<DAC> dacs) async {
    for (final dac in dacs) {
      await promiseToFuture<void>(_jsMySky.loadDacs(dac.$internalObject));
    }
  }

  Future<bool> checkLogin() {
    return promiseToFuture<bool>(_jsMySky.checkLogin());
  }

  Future<String> userId() {
    return promiseToFuture<String>(_jsMySky.userID());
  }

  Future<bool> requestLoginAccess() {
    return promiseToFuture<bool>(_jsMySky.requestLoginAccess());
  }

  Future<JSONResponse> getJSON(String path) async {
    final res = await promiseToFuture<JSJSONResponse>(_jsMySky.getJSON(path));

    return JSONResponse(res.skylink, dartify(res.data));
  }

  Future<dynamic> setJSON(String path, dynamic jsonData) async {
    final res = await promiseToFuture(
      _jsMySky.setJSON(
        path,
        jsify(jsonData),
      ),
    );

    return dartify(res);
  }
}

class JSONResponse {
  dynamic jsonData;
  String skylink;
  JSONResponse(this.skylink, this.jsonData);
}
