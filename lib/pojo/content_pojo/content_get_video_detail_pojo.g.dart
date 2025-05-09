// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_get_video_detail_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentGetVideoDetailPojo _$ContentGetVideoDetailPojoFromJson(
        Map<String, dynamic> json) =>
    ContentGetVideoDetailPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ContentGetVideoDetailPojoToJson(
        ContentGetVideoDetailPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
