import 'package:skynet/src/mysky_js.dart';

import 'package:js/js_util.dart';

class MySky {
  late JSMySky _jsMySky;

  Future<void> load(
    String skappDomain, {
    String portal = 'https://siasky.net/',
  }) async {
    final client = JSSkynetClient(portal);

    _jsMySky = await promiseToFuture<JSMySky>(client.loadMySky(skappDomain));
  }

  Future<void> loadDACs(dac) async {
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
}
