// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_recommendation_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRecommendationPojo _$SearchRecommendationPojoFromJson(
        Map<String, dynamic> json) =>
    SearchRecommendationPojo(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SearchRecommendationPojoToJson(
        SearchRecommendationPojo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
