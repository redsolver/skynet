import 'package:json_annotation/json_annotation.dart';
import 'package:skynet/src/skystandards/types.dart';

part 'profile.g.dart';

@JsonSerializable(includeIfNull: false)
class Profile {
  @JsonKey(ignore: true)
  String? userId;

  String getAvatarUrl() => avatar!.first.url;

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

// TODO Add Hive data
