import 'package:skynet/src/dacs/dac.dart';
import 'package:skynet/src/mysky_js.dart';

import 'package:js/js_util.dart';
import 'package:skynet/src/utils/js.dart';

class MySky {
  late JSMySky _jsMySky;

  Future<void> load(
    String skappDomain, {
    String portal = 'https://siasky.net/',
  }) async {
    final client = JSSkynetClient(portal);

    _jsMySky = await promiseToFuture<JSMySky>(client.loadMySky(skappDomain));
  }

  Future<void> loadDACs(DAC dac) async {
    await _jsMySky.loadDacs(dac.$internalObject);
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

  Future<JSONResponse> setJSON(String path, dynamic jsonData) async {
    final res = await promiseToFuture<JSJSONResponse>(
      _jsMySky.setJSON(
        path,
        jsify(jsonData),
      ),
    );

    return JSONResponse(res.skylink, dartify(res.data));
  }
}

class JSONResponse {
  dynamic jsonData;
  String skylink;
  JSONResponse(this.skylink, this.jsonData);
}
