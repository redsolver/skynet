// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    version: json['version'] as int,
    username: json['username'] as String,
    aboutMe: json['aboutMe'] as String?,
    location: json['location'] as String?,
    topics:
        (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList(),
    avatar: (json['avatar'] as List<dynamic>?)
        ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) {
  final val = <String, dynamic>{
    'version': instance.version,
    'username': instance.username,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('aboutMe', instance.aboutMe);
  writeNotNull('location', instance.location);
  writeNotNull('topics', instance.topics);
  writeNotNull('avatar', instance.avatar);
  return val;
}
