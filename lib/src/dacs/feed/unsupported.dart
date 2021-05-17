import 'package:skynet/src/client.dart';
import 'package:skynet/src/dacs/dac.dart';

import 'package:skynet/src/skystandards/types.dart';

class FeedDAC extends DAC {
  FeedDAC(SkynetClient skynetClient) : super(skynetClient) {
    throw 'Platform Not Supported';
  }

  Future<String> createPost(
    PostContent content, {
    List<String> mentions = const [],
  }) async {
    throw 'Platform Not Supported';
  }

  Stream<List<Post>> loadPostsForUser(String userId) {
    throw 'Platform Not Supported';
  }

  Future<Post?> loadPost(String ref) async {
    throw 'Platform Not Supported';
  }

  String get dacDomain {
    throw 'Platform Not Supported';
  }
}
