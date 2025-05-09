import 'package:json_annotation/json_annotation.dart';

part 'search_recommendation_pojo.g.dart';

@JsonSerializable()
class SearchRecommendationPojo {
  final int code;
  final String msg;
  final List<String> data;

  SearchRecommendationPojo({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory SearchRecommendationPojo.fromJson(Map<String, dynamic> json) => _$SearchRecommendationPojoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchRecommendationPojoToJson(this);
}
