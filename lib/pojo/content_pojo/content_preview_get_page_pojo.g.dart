// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_preview_get_page_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentPreviewGetPagePojo _$ContentPreviewGetPagePojoFromJson(
        Map<String, dynamic> json) =>
    ContentPreviewGetPagePojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ContentPreviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContentPreviewGetPagePojoToJson(
        ContentPreviewGetPagePojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
