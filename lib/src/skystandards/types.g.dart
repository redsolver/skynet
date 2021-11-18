// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    commentTo: json['commentTo'] as String?,
    content: json['content'] == null
        ? null
        : PostContent.fromJson(json['content'] as Map<String, dynamic>),
    id: json['id'] is String ? 0 : json['id'] as int?,
    isDeleted: json['isDeleted'] as bool?,
    mentions:
        (json['mentions'] as List<dynamic>?)?.map((e) => e as String).toList(),
    parentHash: json['parentHash'] as String?,
    repostOf: json['repostOf'] as String?,
    ts: json['ts'] as int?,
  );
}

Map<String, dynamic> _$PostToJson(Post instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('commentTo', instance.commentTo);
  writeNotNull('content', instance.content);
  writeNotNull('id', instance.id);
  writeNotNull('isDeleted', instance.isDeleted);
  writeNotNull('mentions', instance.mentions);
  writeNotNull('parentHash', instance.parentHash);
  writeNotNull('repostOf', instance.repostOf);
  writeNotNull('ts', instance.ts);
  return val;
}

PostContent _$PostContentFromJson(Map<String, dynamic> json) {
  return PostContent(
    ext: json['ext'] as Map<String, dynamic>?,
    gallery: (json['gallery'] as List<dynamic>?)
        ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
        .toList(),
    lang: json['lang'] as String?,
    link: json['link'] as String?,
    linkTitle: json['linkTitle'] as String?,
    media: json['media'] == null
        ? null
        : Media.fromJson(json['media'] as Map<String, dynamic>),
    pollOptions: (json['pollOptions'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    text: json['text'] as String?,
    textContentType: json['textContentType'] as String?,
    title: json['title'] as String?,
    topics:
        (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$PostContentToJson(PostContent instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ext', instance.ext);
  writeNotNull('gallery', instance.gallery);
  writeNotNull('lang', instance.lang);
  writeNotNull('link', instance.link);
  writeNotNull('linkTitle', instance.linkTitle);
  writeNotNull('media', instance.media);
  writeNotNull('pollOptions', instance.pollOptions);
  writeNotNull('tags', instance.tags);
  writeNotNull('text', instance.text);
  writeNotNull('textContentType', instance.textContentType);
  writeNotNull('title', instance.title);
  writeNotNull('topics', instance.topics);
  return val;
}

Media _$MediaFromJson(Map<String, dynamic> json) {
  return Media(
    aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
    audio: (json['audio'] as List<dynamic>?)
        ?.map((e) => Audio.fromJson(e as Map<String, dynamic>))
        .toList(),
    blurHash: json['blurHash'] as String?,
    image: (json['image'] as List<dynamic>?)
        ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
        .toList(),
    mediaDuration: json['mediaDuration'] as int?,
    video: (json['video'] as List<dynamic>?)
        ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$MediaToJson(Media instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('aspectRatio', instance.aspectRatio);
  writeNotNull('audio', instance.audio);
  writeNotNull('blurHash', instance.blurHash);
  writeNotNull('image', instance.image);
  writeNotNull('mediaDuration', instance.mediaDuration);
  writeNotNull('video', instance.video);
  return val;
}

Audio _$AudioFromJson(Map<String, dynamic> json) {
  return Audio(
    ext: json['ext'] as String,
    url: json['url'] as String,
    abr: json['abr'] as String?,
    acodec: json['acodec'] as String?,
  );
}

Map<String, dynamic> _$AudioToJson(Audio instance) {
  final val = <String, dynamic>{
    'ext': instance.ext,
    'url': instance.url,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('abr', instance.abr);
  writeNotNull('acodec', instance.acodec);
  return val;
}

Image _$ImageFromJson(Map<String, dynamic> json) {
  return Image(
    ext: json['ext'] as String,
    url: json['url'] as String,
    h: json['h'] as int,
    w: json['w'] as int,
  );
}

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'ext': instance.ext,
      'url': instance.url,
      'h': instance.h,
      'w': instance.w,
    };

Video _$VideoFromJson(Map<String, dynamic> json) {
  return Video(
    ext: json['ext'] as String,
    url: json['url'] as String,
    fps: (json['fps'] as num?)?.toDouble(),
    vcodec: json['vcodec'] as String?,
  );
}

Map<String, dynamic> _$VideoToJson(Video instance) {
  final val = <String, dynamic>{
    'ext': instance.ext,
    'url': instance.url,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fps', instance.fps);
  writeNotNull('vcodec', instance.vcodec);
  return val;
}
