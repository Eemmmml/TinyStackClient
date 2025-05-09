// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_search_history_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncSearchHistoryPojo _$SyncSearchHistoryPojoFromJson(
        Map<String, dynamic> json) =>
    SyncSearchHistoryPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] as bool,
    );

Map<String, dynamic> _$SyncSearchHistoryPojoToJson(
        SyncSearchHistoryPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
