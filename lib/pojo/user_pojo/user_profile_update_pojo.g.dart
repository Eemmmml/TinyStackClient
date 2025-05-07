// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_update_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileUpdatePojo _$UserProfileUpdatePojoFromJson(
        Map<String, dynamic> json) =>
    UserProfileUpdatePojo(
      userID: (json['userID'] as num).toInt(),
      username: json['username'] as String?,
      avatarImageUrl: json['avatarImageUrl'] as String?,
      description: json['description'] as String?,
      interests: (json['interests'] as num?)?.toInt(),
      compositions: (json['compositions'] as num?)?.toInt(),
      fans: (json['fans'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserProfileUpdatePojoToJson(
        UserProfileUpdatePojo instance) =>
    <String, dynamic>{
      'userID': instance.userID,
      'username': instance.username,
      'avatarImageUrl': instance.avatarImageUrl,
      'description': instance.description,
      'interests': instance.interests,
      'compositions': instance.compositions,
      'fans': instance.fans,
    };
