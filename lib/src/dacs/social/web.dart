import 'package:js/js_util.dart';
import 'package:skynet/src/client.dart';
import 'package:skynet/src/dacs/dac.dart';

import 'js.dart';

class SocialDAC extends DAC {
  late JSSocialDAC _jsSocialDAC;
  SocialDAC(SkynetClient skynetClient) : super(skynetClient) {
    _jsSocialDAC = JSSocialDAC();
  }

  JSSocialDAC get $internalObject => _jsSocialDAC;

  Future<List<String>> getFollowingForUser(String userId) async {
    final res = await promiseToFuture<List<dynamic>>(
      _jsSocialDAC.getFollowingForUser(userId),
    );
    return res.cast<String>();
  }

  Future<int> getFollowingCountForUser(String userId) async {
    final res = await promiseToFuture<int>(
      _jsSocialDAC.getFollowingCountForUser(userId),
    );
    return res;
  }

  Future<bool> isFollowing(String userId) async {
    final res = await promiseToFuture<bool>(
      _jsSocialDAC.isFollowing(userId),
    );
    return res;
  }

  Future<void> follow(String userId) async {
    final res = await promiseToFuture<SocialDACResponse>(
      _jsSocialDAC.follow(userId),
    );
    if (res.success) {
      return;
    } else {
      throw res.error ?? 'Error: No error';
    }
  }

  Future<void> unfollow(String userId) async {
    final res = await promiseToFuture<SocialDACResponse>(
      _jsSocialDAC.unfollow(userId),
    );
    if (res.success) {
      return;
    } else {
      throw res.error ?? 'Error: No error';
    }
  }

  String get dacDomain => _jsSocialDAC.dacDomain;
}
