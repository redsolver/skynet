import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skynet/src/skystandards/fs.dart';

part 'types.g.dart';

/* Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson()); */

@HiveType(typeId: 120)
class FeedPage {
  final String $schema =
      'https://skystandards.hns.siasky.net/draft-01/feedPage.schema.json';

  @HiveField(1)
  List<Post> items;

  @HiveField(2)
  final int revision;

  FeedPage({this.revision = -1, required this.items});

  Map toJson() => {
        '\$schema': $schema,
        'items': items,
      };
}

/**
 * A representation of a post
 */
@HiveType(typeId: 111)
@JsonSerializable(includeIfNull: false)
class Post {
  String get fullRef => id == null ? feedPageUri! : '$feedPageUri/$id';

  String get userId => Uri.parse(fullRef).authority;

  DateTime get postedAt => DateTime.fromMillisecondsSinceEpoch(ts!);

  @HiveField(10)
  @JsonKey(ignore: true)
  Map<String, int>? customReactionCounts;

  @HiveField(2)
  @JsonKey(ignore: true)
  int? customCommentCount;

  @HiveField(3)
  @JsonKey(ignore: true)
  int? customRepostCount;

  @HiveField(4)
  @JsonKey(ignore: true)
  String? feedPageUri;

  Post({
    this.commentTo,
    this.content,
    this.id,
    this.isDeleted,
    this.mentions,
    this.parentHash,
    this.repostOf,
    this.ts,
  });

  /**
     * Full ID of the post this posts is commenting on
     */
  @HiveField(5)
  String? commentTo;
  @HiveField(6)
  PostContent? content;
  /**
     * This ID MUST be unique on the page this post is on. For example, this post could have the
     * full id d448f1562c20dbafa42badd9f88560cd1adb2f177b30f0aa048cb243e55d37bd/feed/posts/1/5
     * (userId/structure/feedId/pageId/postId)
     */
  @HiveField(1)
  int? id;
  /**
     * If this post is deleted
     */
  @HiveField(7)
  bool? isDeleted;
  /**
     * User IDs of users being mentioned in this post (also used for comments)
     */
  @HiveField(8)
  List<String>? mentions;
  /**
     * Multihash of the Canonical JSON (http://wiki.laptop.org/go/Canonical_JSON) string of the
     * post being reposted or commented on to prevent unexpected edits
     */
  @HiveField(9)
  String? parentHash;
  /**
     * Full ID of the post being reposted (If this key is present, this post is a repost and
     * does not need to contain a "content")
     */
  @HiveField(11)
  String? repostOf;
  /**
     * Unix timestamp (in milliseconds) when this post was created/posted
     */
  @HiveField(12)
  int? ts;

  factory Post.fromJson(Map<String, dynamic> json, {String? feedPageUri}) {
    final post = _$PostFromJson(json);
    post.feedPageUri = feedPageUri;
    return post;
  }
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

/**
 * The content of a post
 */
@HiveType(typeId: 112)
@JsonSerializable(includeIfNull: false)
class PostContent {
  PostContent({
    this.ext,
    this.files,
    this.lang,
    this.link,
    this.linkTitle,
    this.media,
    this.pollOptions,
    this.tags,
    this.text,
    this.textContentType,
    this.title,
    this.topics,
  });

  /**
     * Can be used by applications to add more metadata
     */
  @HiveField(1)
  Map<String, dynamic>? ext;

  @HiveField(2)
  List<DirectoryFile>? files;
  /**
     * ISO 639-1 Alpha-2 language code
     */
  String? lang;
  /**
     * Can be used as a link to a url referred by this post
     */
  @HiveField(3)
  String? link;
  /**
     * title of the url, only used for preview
     */
  @HiveField(4)
  String? linkTitle;
  /**
     * A media object can contain an image, video, audio or combination of all of them
     */
  @HiveField(5)
  Media? media;
  /**
     * Used for polls
     */
  @HiveField(6)
  Map<String, String>? pollOptions;
  /**
     * Defines special attributes of this post which have a special meaning which can be
     * interpreted by the application showing this post
     */
  @HiveField(7)
  List<String>? tags;
  /**
     * Text content of the post or description
     */
  @HiveField(8)
  String? text;
  /**
     * The content type of text
     */
  @HiveField(9)
  String? textContentType;
  /**
     * higlighted and used as title of the post when available
     */
  @HiveField(10)
  String? title;
  /**
     * Can contain multiple topics (hashtags) this post fits into
     */
  // @HiveField(11)
  List<String>? topics;

  factory PostContent.fromJson(Map<String, dynamic> json) =>
      _$PostContentFromJson(json);
  Map<String, dynamic> toJson() => _$PostContentToJson(this);
}

/**
 * A media object (image, audio or video). More specific media formats should be listed
 * first
 *
 * A media object can contain an image, video, audio or combination of all of them
 */
@HiveType(typeId: 113)
@JsonSerializable(includeIfNull: false)
class Media {
  Media({
    this.aspectRatio,
    this.audio,
    this.blurHash,
    this.image,
    this.mediaDuration,
    this.video,
  });

  /**
     * Aspect ratio of the image and/or video
     */
  @HiveField(1)
  double? aspectRatio;

  @HiveField(2)
  List<Audio>? audio;
  /**
     * BlurHash of the image shown while loading or not shown due to tags (spoiler or nsfw)
     */
  @HiveField(3)
  String? blurHash;

  @HiveField(4)
  List<Image>? image;
  /**
     * Duration of the audio or video in milliseconds
     */
  @HiveField(5)
  int? mediaDuration;

  @HiveField(6)
  List<Video>? video;

  Video get preferredVideo => video!.first;
  Image get preferredImage => image!.first;
  Audio get preferredAudio => audio!.first;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);

  @JsonKey(ignore: true)
  late Uint8List bytes;
}

/**
 * An available media format listed in a media object
 */
@HiveType(typeId: 114)
@JsonSerializable(includeIfNull: false)
class Audio {
  Audio({
    required this.ext,
    required this.url,
    this.abr,
    this.acodec,
  });

  /**
     * file extension of this media format
     */
  @HiveField(1)
  String ext;
  @HiveField(2)
  String url;
  /**
     * quality of the audio in kbps
     */
  @HiveField(3)
  String? abr;
  /**
     * audio codec used by this format
     */
  @HiveField(4)
  String? acodec;

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);
  Map<String, dynamic> toJson() => _$AudioToJson(this);
}

/**
 * An available media format listed in a media object
 */
@HiveType(typeId: 115)
@JsonSerializable(includeIfNull: false)
class Image {
  Image({
    this.ext,
    required this.url,
    this.h,
    this.w,
  });

  /**
     * file extension of this media format
     */
  @HiveField(1)
  String? ext;
  @HiveField(2)
  String url;
  /**
     * Height of the image
     */
  @HiveField(3)
  int? h;
  /**
     * Width of the image
     */
  @HiveField(4)
  int? w;
  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

/**
 * An available media format listed in a media object
 */
@HiveType(typeId: 116)
@JsonSerializable(includeIfNull: false)
class Video {
  Video({
    required this.ext,
    required this.url,
    this.fps,
    this.vcodec,
  });

  /**
     * file extension of this media format
     */
  @HiveField(1)
  String ext;
  @HiveField(2)
  String url;
  /**
     * Frames per second of this format
     */
  @HiveField(3)
  double? fps;
  /**
     * video codec used by this format
     */
  @HiveField(4)
  String? vcodec;
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
