// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DirectoryIndexAdapter extends TypeAdapter<DirectoryIndex> {
  @override
  final int typeId = 121;

  @override
  DirectoryIndex read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DirectoryIndex(
      directories: (fields[1] as Map).cast<String, DirectoryDirectory>(),
      files: (fields[2] as Map).cast<String, DirectoryFile>(),
    );
  }

  @override
  void write(BinaryWriter writer, DirectoryIndex obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.directories)
      ..writeByte(2)
      ..write(obj.files);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryIndexAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DirectoryDirectoryAdapter extends TypeAdapter<DirectoryDirectory> {
  @override
  final int typeId = 122;

  @override
  DirectoryDirectory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DirectoryDirectory(
      name: fields[1] as String,
      created: fields[2] as int,
    )
      ..uri = fields[3] as String?
      ..key = fields[4] as String?;
  }

  @override
  void write(BinaryWriter writer, DirectoryDirectory obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.uri)
      ..writeByte(4)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryDirectoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DirectoryFileAdapter extends TypeAdapter<DirectoryFile> {
  @override
  final int typeId = 123;

  @override
  DirectoryFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DirectoryFile(
      name: fields[1] as String,
      created: fields[7] as int,
      modified: fields[3] as int,
      version: fields[2] as int,
      file: fields[6] as FileData,
      ext: (fields[8] as Map?)?.cast<String, dynamic>(),
      history: (fields[5] as Map?)?.cast<String, FileData>(),
      mimeType: fields[4] as String?,
    )
      ..uri = fields[9] as String?
      ..key = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, DirectoryFile obj) {
    writer
      ..writeByte(10)
      ..writeByte(8)
      ..write(obj.ext)
      ..writeByte(7)
      ..write(obj.created)
      ..writeByte(6)
      ..write(obj.file)
      ..writeByte(5)
      ..write(obj.history)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(3)
      ..write(obj.modified)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.version)
      ..writeByte(9)
      ..write(obj.uri)
      ..writeByte(10)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileDataAdapter extends TypeAdapter<FileData> {
  @override
  final int typeId = 124;

  @override
  FileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileData(
      chunkSize: fields[3] as int?,
      encryptionType: fields[5] as String?,
      hash: fields[6] as String,
      key: fields[8] as String?,
      ts: fields[9] as int,
      url: fields[10] as String,
      size: fields[2] as int,
      padding: fields[4] as int?,
      ext: (fields[1] as Map?)?.cast<String, dynamic>(),
      hashes: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FileData obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.ext)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.chunkSize)
      ..writeByte(4)
      ..write(obj.padding)
      ..writeByte(5)
      ..write(obj.encryptionType)
      ..writeByte(6)
      ..write(obj.hash)
      ..writeByte(7)
      ..write(obj.hashes)
      ..writeByte(8)
      ..write(obj.key)
      ..writeByte(9)
      ..write(obj.ts)
      ..writeByte(10)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectoryIndex _$DirectoryIndexFromJson(Map<String, dynamic> json) =>
    DirectoryIndex(
      directories: (json['directories'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, DirectoryDirectory.fromJson(e as Map<String, dynamic>)),
      ),
      files: (json['files'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, DirectoryFile.fromJson(e as Map<String, dynamic>)),
      ),
      $schema: json[r'$schema'] as String? ??
          'https://skystandards.hns.siasky.net/draft-01/directoryIndex.schema.json',
    );

Map<String, dynamic> _$DirectoryIndexToJson(DirectoryIndex instance) =>
    <String, dynamic>{
      r'$schema': instance.$schema,
      'directories': instance.directories,
      'files': instance.files,
    };

DirectoryDirectory _$DirectoryDirectoryFromJson(Map<String, dynamic> json) =>
    DirectoryDirectory(
      name: json['name'] as String,
      created: json['created'] as int,
    );

Map<String, dynamic> _$DirectoryDirectoryToJson(DirectoryDirectory instance) =>
    <String, dynamic>{
      'created': instance.created,
      'name': instance.name,
    };

DirectoryFile _$DirectoryFileFromJson(Map<String, dynamic> json) =>
    DirectoryFile(
      name: json['name'] as String,
      created: json['created'] as int,
      modified: json['modified'] as int,
      version: json['version'] as int,
      file: FileData.fromJson(json['file'] as Map<String, dynamic>),
      ext: json['ext'] as Map<String, dynamic>?,
      history: (json['history'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, FileData.fromJson(e as Map<String, dynamic>)),
          ) ??
          {},
      mimeType: json['mimeType'] as String?,
    );

Map<String, dynamic> _$DirectoryFileToJson(DirectoryFile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ext', instance.ext);
  val['created'] = instance.created;
  val['file'] = instance.file;
  writeNotNull('history', instance.history);
  writeNotNull('mimeType', instance.mimeType);
  val['modified'] = instance.modified;
  val['name'] = instance.name;
  val['version'] = instance.version;
  return val;
}

FileData _$FileDataFromJson(Map<String, dynamic> json) => FileData(
      chunkSize: json['chunkSize'] as int?,
      encryptionType: json['encryptionType'] as String?,
      hash: json['hash'] as String,
      key: json['key'] as String?,
      ts: json['ts'] as int,
      url: json['url'] as String,
      size: json['size'] as int,
      padding: json['padding'] as int? ?? 0,
      ext: json['ext'] as Map<String, dynamic>?,
      hashes:
          (json['hashes'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$FileDataToJson(FileData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ext', instance.ext);
  val['size'] = instance.size;
  writeNotNull('chunkSize', instance.chunkSize);
  writeNotNull('padding', instance.padding);
  writeNotNull('encryptionType', instance.encryptionType);
  val['hash'] = instance.hash;
  writeNotNull('hashes', instance.hashes);
  writeNotNull('key', instance.key);
  val['ts'] = instance.ts;
  val['url'] = instance.url;
  return val;
}
