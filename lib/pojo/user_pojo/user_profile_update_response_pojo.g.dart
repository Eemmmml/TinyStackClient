// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_update_response_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileUpdateResponsePojo _$UserProfileUpdateResponsePojoFromJson(
        Map<String, dynamic> json) =>
    UserProfileUpdateResponsePojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] as bool?,
    );

Map<String, dynamic> _$UserProfileUpdateResponsePojoToJson(
        UserProfileUpdateResponsePojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
