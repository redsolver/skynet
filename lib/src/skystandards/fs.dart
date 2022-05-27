import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fs.g.dart';

/**
 * Index file of a directory, contains all directories and files in this specific directory
 */
@HiveType(typeId: 121)
@JsonSerializable(includeIfNull: false)
class DirectoryIndex {
  String $schema;

  DirectoryIndex({
    required this.directories,
    required this.files,
    this.$schema =
        'https://skystandards.hns.siasky.net/draft-01/directoryIndex.schema.json',
  });

  /**
     * subdirectories in this directory
     */
  @HiveField(1)
  Map<String, DirectoryDirectory> directories;
  /**
     * files in this directory
     */
  @HiveField(2)
  Map<String, DirectoryFile> files;

  /**
     * Used if this directory is an index
     */
  // Map<String, dynamic>? index;

  factory DirectoryIndex.fromJson(Map<String, dynamic> json) =>
      _$DirectoryIndexFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoryIndexToJson(this);
}

@HiveType(typeId: 122)
@JsonSerializable(includeIfNull: false)
class DirectoryDirectory {
  DirectoryDirectory({
    required this.name,
    required this.created,
  });
  /**
     * Unix timestamp (in milliseconds) when this directory was created
     */
  @HiveField(2)
  int created;

  /**
     * Name of this directory
     */
  @HiveField(1)
  String name;

  @HiveField(3)
  @JsonKey(ignore: true)
  String? uri;

  @HiveField(4)
  @JsonKey(ignore: true)
  String? key;

  @JsonKey(ignore: true)
  int? size;

  factory DirectoryDirectory.fromJson(Map<String, dynamic> json) =>
      _$DirectoryDirectoryFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoryDirectoryToJson(this);
}

/**
 * Metadata of a file, can contain multiple versions
 */
@HiveType(typeId: 123)
@JsonSerializable(includeIfNull: false)
class DirectoryFile {
  DirectoryFile({
    required this.name,
    required this.created,
    required this.modified,
    required this.version,
    required this.file,
    this.ext,
    this.history,
    this.mimeType,
  });

  /**
     * Can be used by applications to add more metadata
     */
  @HiveField(8)
  Map<String, dynamic>? ext;

  /**
     * Unix timestamp (in milliseconds) when this file was created
     */
  @HiveField(7)
  int created;
  /**
     * The current version of a file
     */
  @HiveField(6)
  FileData file;
  /**
     * Historic versions of a file
     */
  @HiveField(5)
  @JsonKey(defaultValue: {})
  Map<String, FileData>? history;
  /**
     * MIME Type of the file, optional
     */
  @HiveField(4)
  String? mimeType;
  /**
     * Unix timestamp (in milliseconds) when this file was last modified
     */
  @HiveField(3)
  int modified;
  /**
     * Name of this file
     */
  @HiveField(1)
  String name;
  /**
     * Current version of the file. When this file was already modified 9 times, this value is 9
     */
  @HiveField(2)
  int version;

  @HiveField(9)
  @JsonKey(ignore: true)
  String? uri;

  @HiveField(10)
  @JsonKey(ignore: true)
  String? key;

  factory DirectoryFile.fromJson(Map<String, dynamic> json) =>
      _$DirectoryFileFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoryFileToJson(this);
}

/**
 * The current version of a file
 *
 * Specific version of a file. Immutable.
 */
@HiveType(typeId: 124)
@JsonSerializable(includeIfNull: false)
class FileData {
  FileData({
    required this.chunkSize,
    required this.encryptionType,
    required this.hash,
    required this.key,
    required this.ts,
    required this.url,
    required this.size,
    this.padding = 0,
    this.ext,
    this.hashes,
  });

  /**
     * Can be used by applications to add more metadata
     */
  @HiveField(1)
  Map<String, dynamic>? ext;

  /**
     * Unencrypted size of the file, in bytes
     */
  @HiveField(2)
  int size;
  /**
     * maxiumum size of every unencrypted file chunk in bytes
     */
  @HiveField(3)
  int? chunkSize;

  @HiveField(4)
  int? padding;
  /**
     * Which algorithm is used to encrypt and decrypt this file
     */
  @HiveField(5)
  String? encryptionType;
  /**
     * Multihash of the unencrypted file, starts with 1220 for sha256
     */
  @HiveField(6)
  String hash;

  @HiveField(7)
  List<String>? hashes;
  /**
     * The secret key used to encrypt this file, base64Url-encoded
     */
  @HiveField(8)
  String? key;
  /**
     * Unix timestamp (in milliseconds) when this version was added to the FileSystem DAC
     */
  @HiveField(9)
  int ts;
  /**
     * URL where the encrypted file blob can be downloaded, usually a skylink (sia://)
     */
  @HiveField(10)
  String url;

  factory FileData.fromJson(Map<String, dynamic> json) =>
      _$FileDataFromJson(json);
  Map<String, dynamic> toJson() => _$FileDataToJson(this);
}
