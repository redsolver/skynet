import 'dart:convert';

import 'package:js/js_util.dart';
import 'package:skynet/src/client.dart';
import 'package:skynet/src/dacs/dac.dart';

import 'package:skynet/src/skystandards/types.dart';
import 'package:skynet/src/utils/js.dart';
import 'generic.dart' as generic;

import 'js.dart';

class FeedDAC extends DAC {
  late JSFeedDAC _jsFeedDAC;
  FeedDAC(SkynetClient skynetClient) : super(skynetClient) {
    _jsFeedDAC = JSFeedDAC();
  }

  JSFeedDAC get $internalObject => _jsFeedDAC;

  Stream<List<Post>> loadPostsForUser(String userId) =>
      generic.loadPostsForUser(
        userId,
        skynetClient: skynetClient,
      );

  Future<String> createPost(
    PostContent content, {
    List<String> mentions = const [],
  }) async {
    final res = await promiseToFuture<CreatePostResponse>(
      _jsFeedDAC.createPost(json.encode(content)),
    );
    if (res.success) {
      if (res.ref == null) throw 'Empty reference';
      return res.ref ?? '';
    } else {
      throw res.error ?? '';
    }
  }

  Future<Post?> loadPost(String ref) async {
    final res = await promiseToFuture<dynamic>(
      _jsFeedDAC.loadPost(ref),
    );

    if (res == null) {
      return null;
    } else {
      return Post.fromJson(dartify(res));
    }
  }

  String get dacDomain => _jsFeedDAC.dacDomain;
}
