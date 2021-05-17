import 'package:skynet/src/client.dart';
import 'package:skynet/src/dacs/dac.dart';

import 'package:skynet/src/skystandards/types.dart';
import 'generic.dart' as generic;

class FeedDAC extends DAC {
  FeedDAC(SkynetClient skynetClient) : super(skynetClient);

  Stream<List<Post>> loadPostsForUser(String userId) =>
      generic.loadPostsForUser(
        userId,
        skynetClient: skynetClient,
      );

  Future<String> createPost(
    PostContent content, {
    List<String> mentions = const [],
  }) async {
    throw 'Platform Not Supported';
  }

  Future<Post?> loadPost(String ref) async {
    throw 'Platform Not Supported';
  }

  String get dacDomain {
    throw 'Platform Not Supported';
  }
}
