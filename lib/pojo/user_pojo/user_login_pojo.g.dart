// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLoginPojo _$UserLoginPojoFromJson(Map<String, dynamic> json) =>
    UserLoginPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : UserLoginDataPojo.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserLoginPojoToJson(UserLoginPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

UserLoginDataPojo _$UserLoginDataPojoFromJson(Map<String, dynamic> json) =>
    UserLoginDataPojo(
      userID: (json['userID'] as num).toInt(),
      token: json['token'] as String,
    );

Map<String, dynamic> _$UserLoginDataPojoToJson(UserLoginDataPojo instance) =>
    <String, dynamic>{
      'userID': instance.userID,
      'token': instance.token,
    };
