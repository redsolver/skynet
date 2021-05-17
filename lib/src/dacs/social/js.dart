@JS('socialdac')
library socialdac;

import 'package:js/js.dart';

@JS('SocialDAC')
class JSSocialDAC {
  external JSSocialDAC();

  external Future<List<dynamic>> getFollowingForUser(String userId);

  external Future<int> getFollowingCountForUser(String userId);

  external Future<bool> isFollowing(String userId);

  external Future<SocialDACResponse> follow(String userId);

  external Future<SocialDACResponse> unfollow(String userId);

  external String get dacDomain;
}

@JS()
@anonymous
class SocialDACResponse {
  external bool get success;
  external String? get error;
}
