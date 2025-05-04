// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLoginPojo _$UserLoginPojoFromJson(Map<String, dynamic> json) =>
    UserLoginPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$UserLoginPojoToJson(UserLoginPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
