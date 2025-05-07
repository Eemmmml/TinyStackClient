// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_info_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileInfoPojo _$UserProfileInfoPojoFromJson(Map<String, dynamic> json) =>
    UserProfileInfoPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : UserBasicInfo.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProfileInfoPojoToJson(
        UserProfileInfoPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
