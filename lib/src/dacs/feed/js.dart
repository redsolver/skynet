@JS('feeddac')
library feeddac;

import 'package:js/js.dart';

@JS('FeedDAC')
class JSFeedDAC {
  external JSFeedDAC();

  external Future<CreatePostResponse> createPost(String content);

  external Future<dynamic> loadPost(String ref);

  external String get dacDomain;
}

@JS()
@anonymous
class CreatePostResponse {
  external bool get success;
  external String? get error;
  external String? get ref;
}
