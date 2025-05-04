// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_basic_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBasicInfo _$UserBasicInfoFromJson(Map<String, dynamic> json) =>
    UserBasicInfo(
      username: json['username'] as String,
      avatarImageUrl: json['avatarImageUrl'] as String,
      description: json['description'] as String,
      interests: (json['interests'] as num).toInt(),
      compositions: (json['compositions'] as num).toInt(),
      fans: (json['fans'] as num).toInt(),
    );

Map<String, dynamic> _$UserBasicInfoToJson(UserBasicInfo instance) =>
    <String, dynamic>{
      'username': instance.username,
      'avatarImageUrl': instance.avatarImageUrl,
      'description': instance.description,
      'interests': instance.interests,
      'compositions': instance.compositions,
      'fans': instance.fans,
    };
