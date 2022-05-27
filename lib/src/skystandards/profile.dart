import 'package:json_annotation/json_annotation.dart';
import 'types.dart';
import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 110)
@JsonSerializable(includeIfNull: false)
class Profile {
  @JsonKey(ignore: true)
  @HiveField(1)
  String? userId;

  String getAvatarUrl() => (avatar ?? []).isEmpty
      ? 'sia://CABdyKgcVLkjdsa0HIjBfNicRv0pqU7YL-tgrfCo23DmWw'
      : avatar!.first.url;

  Profile({
    required this.version,
    required this.username,
    this.aboutMe,
    this.location,
    this.topics,
    this.avatar,
  });

  @HiveField(0)
  int version;

  @HiveField(2)
  String username;

  @HiveField(3)
  String? aboutMe;

  @HiveField(4)
  String? location;

  List<String>? topics;

  @HiveField(5)
  List<Image>? avatar;

  @HiveField(6)
  List<Map>? rels;

  bool get isTopic => userId![0] == '#';

  @JsonKey(ignore: true)
  @HiveField(7)
  int? customFollowerCount;

  @JsonKey(ignore: true)
  @HiveField(8)
  int? customFollowingCount;


  @JsonKey(ignore: true)
  @HiveField(9)
  Map<String, dynamic>? ext;

  Profile.user({
    String? id,
    required this.username,
    String? bio,
    String? picture,
    String? location,
    this.version = 1, // TODO
  }) {
    userId = id!;
    this.aboutMe = bio!;
    this.avatar = [Image(ext: 'png', url: picture!, h: -1, w: -1)];
    this.location = location!;
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
