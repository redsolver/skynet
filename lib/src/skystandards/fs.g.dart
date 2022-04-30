// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectoryIndex _$DirectoryIndexFromJson(Map<String, dynamic> json) {
  return DirectoryIndex(
    directories: (json['directories'] as Map<String, dynamic>).map(
      (k, e) =>
          MapEntry(k, DirectoryDirectory.fromJson(e as Map<String, dynamic>)),
    ),
    files: (json['files'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, DirectoryFile.fromJson(e as Map<String, dynamic>)),
    ),
    index: json['index'] as Map<String, dynamic>?,
    $schema: json[r'$schema'] as String? ??
        'https://skystandards.hns.siasky.net/draft-01/directoryIndex.schema.json',
  );
}

Map<String, dynamic> _$DirectoryIndexToJson(DirectoryIndex instance) {
  final val = <String, dynamic>{
    r'$schema': instance.$schema,
    'directories': instance.directories,
    'files': instance.files,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('index', instance.index);

  return val;
}

DirectoryDirectory _$DirectoryDirectoryFromJson(Map<String, dynamic> json) {
  return DirectoryDirectory(
    name: json['name'] as String,
    created: json['created'] as int,
  );
}

Map<String, dynamic> _$DirectoryDirectoryToJson(DirectoryDirectory instance) =>
    <String, dynamic>{
      'created': instance.created,
      'name': instance.name,
    };

DirectoryFile _$DirectoryFileFromJson(Map<String, dynamic> json) {
  return DirectoryFile(
    ext: json['ext']?.cast<String, dynamic>(),
    name: json['name'] as String,
    created: json['created'] as int,
    modified: json['modified'] as int,
    version: json['version'] as int,
    file: FileData.fromJson(json['file'] as Map<String, dynamic>),
    history: (json['history'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, FileData.fromJson(e as Map<String, dynamic>)),
        ) ??
        {},
    mimeType: json['mimeType'] as String?,
  );
}

Map<String, dynamic> _$DirectoryFileToJson(DirectoryFile instance) {
  final val = <String, dynamic>{
    'created': instance.created,
    'file': instance.file,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('history', instance.history);
  writeNotNull('mimeType', instance.mimeType);
  writeNotNull('ext', instance.ext);
  val['modified'] = instance.modified;
  val['name'] = instance.name;
  val['version'] = instance.version;
  return val;
}

FileData _$FileDataFromJson(Map<String, dynamic> json) {
  return FileData(
    ext: json['ext']?.cast<String, dynamic>(),
    chunkSize: json['chunkSize'] as int?,
    padding: (json['padding'] ?? 0) as int?,
    encryptionType: json['encryptionType'] as String?,
    hash: json['hash'] as String,
    key: json['key'] as String?,
    ts: json['ts'] as int,
    url: json['url'] as String,
    size: json['size'] as int,
    hashes: json['hashes']?.cast<String>(),
  );
}

Map<String, dynamic> _$FileDataToJson(FileData instance) {
  final val = <String, dynamic>{
    'size': instance.size,
    'hash': instance.hash,
    'ts': instance.ts,
    'url': instance.url,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }
  writeNotNull('chunkSize', instance.chunkSize);
  writeNotNull('padding', instance.padding);
  writeNotNull('encryptionType', instance.encryptionType);
  writeNotNull('key', instance.key);

  writeNotNull('ext', instance.ext);
  writeNotNull('hashes', instance.hashes);
  return val;
}
