// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistoryListPojo _$SearchHistoryListPojoFromJson(
        Map<String, dynamic> json) =>
    SearchHistoryListPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$SearchHistoryListPojoToJson(
        SearchHistoryListPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

SearchHistoryPojo _$SearchHistoryPojoFromJson(Map<String, dynamic> json) =>
    SearchHistoryPojo(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      keyword: json['keyword'] as String,
      searchCount: (json['searchCount'] as num).toInt(),
      createTime: DateTime.parse(json['createTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$SearchHistoryPojoToJson(SearchHistoryPojo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'keyword': instance.keyword,
      'searchCount': instance.searchCount,
      'createTime': instance.createTime.toIso8601String(),
      'updateTime': instance.updateTime.toIso8601String(),
    };
