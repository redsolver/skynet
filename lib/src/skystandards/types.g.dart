// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedPageAdapter extends TypeAdapter<FeedPage> {
  @override
  final int typeId = 120;

  @override
  FeedPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedPage(
      revision: fields[2] as int,
      items: (fields[1] as List).cast<Post>(),
    );
  }

  @override
  void write(BinaryWriter writer, FeedPage obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.revision);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 111;

  @override
  Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post(
      commentTo: fields[5] as String?,
      content: fields[6] as PostContent?,
      id: fields[1] as int?,
      isDeleted: fields[7] as bool?,
      mentions: (fields[8] as List?)?.cast<String>(),
      parentHash: fields[9] as String?,
      repostOf: fields[11] as String?,
      ts: fields[12] as int?,
    )
      ..customReactionCounts = (fields[10] as Map?)?.cast<String, int>()
      ..customCommentCount = fields[2] as int?
      ..customRepostCount = fields[3] as int?
      ..feedPageUri = fields[4] as String?;
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(12)
      ..writeByte(10)
      ..write(obj.customReactionCounts)
      ..writeByte(2)
      ..write(obj.customCommentCount)
      ..writeByte(3)
      ..write(obj.customRepostCount)
      ..writeByte(4)
      ..write(obj.feedPageUri)
      ..writeByte(5)
      ..write(obj.commentTo)
      ..writeByte(6)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.mentions)
      ..writeByte(9)
      ..write(obj.parentHash)
      ..writeByte(11)
      ..write(obj.repostOf)
      ..writeByte(12)
      ..write(obj.ts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostContentAdapter extends TypeAdapter<PostContent> {
  @override
  final int typeId = 112;

  @override
  PostContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostContent(
      ext: (fields[1] as Map?)?.cast<String, dynamic>(),
      gallery: (fields[2] as List?)?.cast<Media>(),
      link: fields[3] as String?,
      linkTitle: fields[4] as String?,
      media: fields[5] as Media?,
      pollOptions: (fields[6] as Map?)?.cast<String, String>(),
      tags: (fields[7] as List?)?.cast<String>(),
      text: fields[8] as String?,
      textContentType: fields[9] as String?,
      title: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PostContent obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.ext)
      ..writeByte(2)
      ..write(obj.gallery)
      ..writeByte(3)
      ..write(obj.link)
      ..writeByte(4)
      ..write(obj.linkTitle)
      ..writeByte(5)
      ..write(obj.media)
      ..writeByte(6)
      ..write(obj.pollOptions)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.text)
      ..writeByte(9)
      ..write(obj.textContentType)
      ..writeByte(10)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 113;

  @override
  Media read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Media(
      aspectRatio: fields[1] as double?,
      audio: (fields[2] as List?)?.cast<Audio>(),
      blurHash: fields[3] as String?,
      image: (fields[4] as List?)?.cast<Image>(),
      mediaDuration: fields[5] as int?,
      video: (fields[6] as List?)?.cast<Video>(),
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.aspectRatio)
      ..writeByte(2)
      ..write(obj.audio)
      ..writeByte(3)
      ..write(obj.blurHash)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.mediaDuration)
      ..writeByte(6)
      ..write(obj.video);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AudioAdapter extends TypeAdapter<Audio> {
  @override
  final int typeId = 114;

  @override
  Audio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Audio(
      ext: fields[1] as String,
      url: fields[2] as String,
      abr: fields[3] as String?,
      acodec: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Audio obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.ext)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.abr)
      ..writeByte(4)
      ..write(obj.acodec);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImageAdapter extends TypeAdapter<Image> {
  @override
  final int typeId = 115;

  @override
  Image read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Image(
      ext: fields[1] as String?,
      url: fields[2] as String,
      h: fields[3] as int?,
      w: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Image obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.ext)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.h)
      ..writeByte(4)
      ..write(obj.w);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 116;

  @override
  Video read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Video(
      ext: fields[1] as String,
      url: fields[2] as String,
      fps: fields[3] as double?,
      vcodec: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.ext)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.fps)
      ..writeByte(4)
      ..write(obj.vcodec);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      commentTo: json['commentTo'] as String?,
      content: json['content'] == null
          ? null
          : PostContent.fromJson(json['content'] as Map<String, dynamic>),
      id: json['id'] as int?,
      isDeleted: json['isDeleted'] as bool?,
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parentHash: json['parentHash'] as String?,
      repostOf: json['repostOf'] as String?,
      ts: json['ts'] as int?,
    );

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

PostContent _$PostContentFromJson(Map<String, dynamic> json) => PostContent(
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

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
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

Audio _$AudioFromJson(Map<String, dynamic> json) => Audio(
      ext: json['ext'] as String,
      url: json['url'] as String,
      abr: json['abr'] as String?,
      acodec: json['acodec'] as String?,
    );

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

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      ext: json['ext'] as String?,
      url: json['url'] as String,
      h: json['h'] as int?,
      w: json['w'] as int?,
    );

Map<String, dynamic> _$ImageToJson(Image instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ext', instance.ext);
  val['url'] = instance.url;
  writeNotNull('h', instance.h);
  writeNotNull('w', instance.w);
  return val;
}

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      ext: json['ext'] as String,
      url: json['url'] as String,
      fps: (json['fps'] as num?)?.toDouble(),
      vcodec: json['vcodec'] as String?,
    );

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
