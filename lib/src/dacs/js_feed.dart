@JS('feeddac')
library feeddac;

// import 'dart:js';

import 'package:js/js.dart';

// Invokes the JavaScript getter `google.maps.map`.
// external Map get map;

// The `Map` constructor invokes JavaScript `new google.maps.Map(location)`
@JS('FeedDAC')
class JSFeedDAC {
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

/* @JS()
class IContentRecordDAC {
  recordNewContent(...data: IContentCreation[]): Promise<IDACResponse>;
  recordInteraction(...data: IContentInteraction[]): Promise<IDACResponse>;
} */
