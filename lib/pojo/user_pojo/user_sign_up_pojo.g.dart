// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_sign_up_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSignUpPojo _$UserSignUpPojoFromJson(Map<String, dynamic> json) =>
    UserSignUpPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as num).toInt(),
    );

Map<String, dynamic> _$UserSignUpPojoToJson(UserSignUpPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
