import 'package:skynet/src/client.dart';
import 'package:skynet/src/dacs/dac.dart';

class SocialDAC extends DAC {
  SocialDAC(SkynetClient skynetClient) : super(skynetClient) {
    throw 'Platform Not Supported';
  }

  // TODO Add native implementation for this method
  Future<List<String>> getFollowingForUser(String userId) async {
    throw 'Platform Not Supported';
  }

  Future<int> getFollowingCountForUser(String userId) async {
    throw 'Platform Not Supported';
  }

  Future<bool> isFollowing(String userId) async {
    throw 'Platform Not Supported';
  }

  Future<void> follow(String userId) async {
    throw 'Platform Not Supported';
  }

  Future<void> unfollow(String userId) async {
    throw 'Platform Not Supported';
  }

  Future<void> followExternal(
    String platform,
    String userId,
    Map<String, dynamic> data,
  ) async {
    throw 'Platform Not Supported';
  }

  Future<void> unfollowExternal(
    String platform,
    String userId,
  ) async {
    throw 'Platform Not Supported';
  }

  Future<Map<String, dynamic>> getExternalFollowingForUser(
      String userId) async {
    throw 'Platform Not Supported';
  }

  String get dacDomain {
    throw 'Platform Not Supported';
  }
}
