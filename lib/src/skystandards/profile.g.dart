// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 110;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      version: fields[0] as int,
      username: fields[2] as String,
      aboutMe: fields[3] as String?,
      location: fields[4] as String?,
      avatar: (fields[5] as List?)?.cast<Image>(),
    )
      ..userId = fields[1] as String?
      ..rels = (fields[6] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList()
      ..customFollowerCount = fields[7] as int?
      ..customFollowingCount = fields[8] as int?
      ..ext = (fields[9] as Map?)?.cast<String, dynamic>();
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.aboutMe)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.avatar)
      ..writeByte(6)
      ..write(obj.rels)
      ..writeByte(7)
      ..write(obj.customFollowerCount)
      ..writeByte(8)
      ..write(obj.customFollowingCount)
      ..writeByte(9)
      ..write(obj.ext);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
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
