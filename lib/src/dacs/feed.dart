import 'dart:convert';

import 'package:js/js_util.dart';
import 'package:skynet/src/dacs/dac.dart';
import 'package:skynet/src/mysky.dart';
import 'package:skynet/src/skystandards/types.dart';
import 'package:skynet/src/utils/js.dart';

import 'js_feed.dart';

class FeedDAC extends DAC {
  late JSFeedDAC _jsFeedDAC;
  FeedDAC() {
    _jsFeedDAC = JSFeedDAC();
  }

  JSFeedDAC get $internalObject => _jsFeedDAC;

  Future<String> createPost(
    PostContent content, {
    List<String> mentions = const [],
  }) async {
    print(json.encode(content));

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
