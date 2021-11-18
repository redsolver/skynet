import 'package:json_annotation/json_annotation.dart';

// part 'permission.g.dart';

@JsonSerializable(includeIfNull: false)
class Permission {
  final String requestor;
  final String path;
  final int category;
  final int permType;

  Permission(
    this.requestor,
    this.path,
    this.category,
    this.permType,
  );

  factory Permission.fromJson(Map<String, dynamic> json) => Permission(
        json['requestor'],
        json['path'],
        json['category'],
        json['permType'],
      );
  Map<String, dynamic> toJson() => {
        'requestor': requestor,
        'path': path,
        'category': category,
        'permType': permType,
      };
}

// Define category constants for non-TS users.
const PermDiscoverable = 1;
const PermHidden = 2;
const PermLegacySkyID = 3;

/**
 * Defines what type of file is being requested. Discoverable files are visible
 * to the entire world, hidden files are only visible to the user (unless
 * shared), and LegacySkyID files are supported files from the legacy SkyID
 * login system.
 */
class PermCategory {
  static int Discoverable = PermDiscoverable;
  static int Hidden = PermHidden;
  static int LegacySkyID = PermLegacySkyID;
}

// Define type constants for non-TS users.
const PermRead = 4;
const PermWrite = 5;

class PermType {
  static int Read = PermRead;
  static int Write = PermWrite;
}
