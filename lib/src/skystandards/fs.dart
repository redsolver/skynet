import 'package:json_annotation/json_annotation.dart';

part 'fs.g.dart';

/**
 * Index file of a directory, contains all directories and files in this specific directory
 */
@JsonSerializable(includeIfNull: false)
class DirectoryIndex {
  @JsonKey(
      defaultValue:
          'https://skystandards.hns.siasky.net/draft-01/directoryIndex.schema.json')
  String $schema;

  DirectoryIndex({
    required this.directories,
    required this.files,
    this.index,
    this.$schema =
        'https://skystandards.hns.siasky.net/draft-01/directoryIndex.schema.json',
  });

  /**
     * subdirectories in this directory
     */
  Map<String, DirectoryDirectory> directories;
  /**
     * files in this directory
     */
  Map<String, DirectoryFile> files;

  /**
     * Used if this directory is an index
     */
  Map<String, dynamic>? index;

  factory DirectoryIndex.fromJson(Map<String, dynamic> json) =>
      _$DirectoryIndexFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoryIndexToJson(this);
}

@JsonSerializable(includeIfNull: false)
class DirectoryDirectory {
  DirectoryDirectory({
    required this.name,
    required this.created,
  });
  /**
     * Unix timestamp (in milliseconds) when this directory was created
     */
  int created;

  /**
     * Name of this directory
     */
  String name;

  @JsonKey(ignore: true)
  String? uri;

  @JsonKey(ignore: true)
  int? size;

  factory DirectoryDirectory.fromJson(Map<String, dynamic> json) =>
      _$DirectoryDirectoryFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoryDirectoryToJson(this);
}

/**
 * Metadata of a file, can contain multiple versions
 */
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
  Map<String, dynamic>? ext;

  /**
     * Unix timestamp (in milliseconds) when this file was created
     */
  int created;
  /**
     * The current version of a file
     */
  FileData file;
  /**
     * Historic versions of a file
     */
  @JsonKey(defaultValue: {})
  Map<String, FileData>? history;
  /**
     * MIME Type of the file, optional
     */
  String? mimeType;
  /**
     * Unix timestamp (in milliseconds) when this file was last modified
     */
  int modified;
  /**
     * Name of this file
     */
  String name;
  /**
     * Current version of the file. When this file was already modified 9 times, this value is 9
     */
  int version;

  @JsonKey(ignore: true)
  String? uri;

  factory DirectoryFile.fromJson(Map<String, dynamic> json) =>
      _$DirectoryFileFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoryFileToJson(this);
}

/**
 * The current version of a file
 *
 * Specific version of a file. Immutable.
 */
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
  });

  /**
     * Can be used by applications to add more metadata
     */
  Map<String, dynamic>? ext;

  /**
     * Unencrypted size of the file, in bytes
     */
  int size;
  /**
     * maxiumum size of every unencrypted file chunk in bytes
     */
  int chunkSize;

  int padding;
  /**
     * Which algorithm is used to encrypt and decrypt this file
     */
  String encryptionType;
  /**
     * Multihash of the unencrypted file, starts with 1220 for sha256
     */
  String hash;
  /**
     * The secret key used to encrypt this file, base64Url-encoded
     */
  String key;
  /**
     * Unix timestamp (in milliseconds) when this version was added to the FileSystem DAC
     */
  int ts;
  /**
     * URL where the encrypted file blob can be downloaded, usually a skylink (sia://)
     */
  String url;

  factory FileData.fromJson(Map<String, dynamic> json) =>
      _$FileDataFromJson(json);
  Map<String, dynamic> toJson() => _$FileDataToJson(this);
}
