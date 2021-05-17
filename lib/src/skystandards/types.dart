// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'types.g.dart';

/* Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson()); */

/**
 * A representation of a post
 */
@JsonSerializable(includeIfNull: false)
class Post {
  @JsonKey(ignore: true)
  String? fullId;

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
  String? commentTo;
  PostContent? content;
  /**
     * This ID MUST be unique on the page this post is on. For example, this post could have the
     * full id d448f1562c20dbafa42badd9f88560cd1adb2f177b30f0aa048cb243e55d37bd/feed/posts/1/5
     * (userId/structure/feedId/pageId/postId)
     */
  int? id;
  /**
     * If this post is deleted
     */
  bool? isDeleted;
  /**
     * User IDs of users being mentioned in this post (also used for comments)
     */
  List<String>? mentions;
  /**
     * Multihash of the Canonical JSON (http://wiki.laptop.org/go/Canonical_JSON) string of the
     * post being reposted or commented on to prevent unexpected edits
     */
  String? parentHash;
  /**
     * Full ID of the post being reposted (If this key is present, this post is a repost and
     * does not need to contain a "content")
     */
  String? repostOf;
  /**
     * Unix timestamp (in milliseconds) when this post was created/posted
     */
  int? ts;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

/**
 * The content of a post
 */
@JsonSerializable(includeIfNull: false)
class PostContent {
  PostContent({
    this.ext,
    this.gallery,
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
  Map<String, dynamic>? ext;
  /**
     * List of media objects in a "gallery", can be show in a carousel or list
     * useful for app screenshots or galleries
     * NOT TO BE USED for something like music albums, because it prevents individual tracks
     * from being referenced, saved, rated, reposted...
     */
  List<Media>? gallery;
  /**
     * ISO 639-1 Alpha-2 language code
     */
  String? lang;
  /**
     * Can be used as a link to a url referred by this post
     */
  String? link;
  /**
     * title of the url, only used for preview
     */
  String? linkTitle;
  /**
     * A media object can contain an image, video, audio or combination of all of them
     */
  Media? media;
  /**
     * Used for polls
     */
  Map<String, String>? pollOptions;
  /**
     * Defines special attributes of this post which have a special meaning which can be
     * interpreted by the application showing this post
     */
  List<String>? tags;
  /**
     * Text content of the post or description
     */
  String? text;
  /**
     * The content type of text
     */
  String? textContentType;
  /**
     * higlighted and used as title of the post when available
     */
  String? title;
  /**
     * Can contain multiple topics (hashtags) this post fits into
     */
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
  double? aspectRatio;
  List<Audio>? audio;
  /**
     * BlurHash of the image shown while loading or not shown due to tags (spoiler or nsfw)
     */
  String? blurHash;
  List<Image>? image;
  /**
     * Duration of the audio or video in milliseconds
     */
  int? mediaDuration;
  List<Video>? video;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

/**
 * An available media format listed in a media object
 */
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
  String ext;
  String url;
  /**
     * quality of the audio in kbps
     */
  String? abr;
  /**
     * audio codec used by this format
     */
  String? acodec;

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);
  Map<String, dynamic> toJson() => _$AudioToJson(this);
}

/**
 * An available media format listed in a media object
 */
@JsonSerializable(includeIfNull: false)
class Image {
  Image({
    required this.ext,
    required this.url,
    required this.h,
    required this.w,
  });

  /**
     * file extension of this media format
     */
  String ext;
  String url;
  /**
     * Height of the image
     */
  int h;
  /**
     * Width of the image
     */
  int w;
  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

/**
 * An available media format listed in a media object
 */
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
  String ext;
  String url;
  /**
     * Frames per second of this format
     */
  double? fps;
  /**
     * video codec used by this format
     */
  String? vcodec;
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
