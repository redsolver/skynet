import 'package:json_annotation/json_annotation.dart';
import 'package:skynet/src/skystandards/types.dart';

part 'profile.g.dart';

@JsonSerializable(includeIfNull: false)
class Profile {
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

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
