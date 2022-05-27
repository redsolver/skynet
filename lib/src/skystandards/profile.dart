import 'package:json_annotation/json_annotation.dart';
import 'package:skynet/src/skystandards/types.dart';
import 'package:hive/hive.dart';

part 'profile.g.dart';

@JsonSerializable(includeIfNull: false)
class Profile {
  @JsonKey(ignore: true)
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

  int version;
  String username;
  String? aboutMe;
  String? location;
  List<String>? topics;
  List<Image>? avatar;

  @JsonKey(ignore: true)
  List<Map>? rels;

  @JsonKey(ignore: true)
  Map<String, dynamic>? ext;

  bool get isTopic => userId![0] == '#';

  @JsonKey(ignore: true)
  int? customFollowerCount;

  @JsonKey(ignore: true)
  int? customFollowingCount;

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
