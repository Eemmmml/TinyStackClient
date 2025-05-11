// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sever_search_result_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerSearchResponsePojo _$ServerSearchResponsePojoFromJson(
        Map<String, dynamic> json) =>
    ServerSearchResponsePojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ServerSearchResponsePojoToJson(
        ServerSearchResponsePojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

ServerSearchResultPojo _$ServerSearchResultPojoFromJson(
        Map<String, dynamic> json) =>
    ServerSearchResultPojo(
      contentId: json['contentId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      title: json['title'] as String?,
      uploaderId: (json['uploaderId'] as num?)?.toInt(),
      uploaderName: json['uploaderName'] as String?,
      fans: (json['fans'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      publishTime: json['publishTime'] == null
          ? null
          : DateTime.parse(json['publishTime'] as String),
      ex: json['ex'] as String?,
    );

Map<String, dynamic> _$ServerSearchResultPojoToJson(
        ServerSearchResultPojo instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'coverUrl': instance.coverUrl,
      'avatarUrl': instance.avatarUrl,
      'title': instance.title,
      'uploaderId': instance.uploaderId,
      'uploaderName': instance.uploaderName,
      'fans': instance.fans,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'type': instance.type,
      'publishTime': instance.publishTime?.toIso8601String(),
      'ex': instance.ex,
    };
