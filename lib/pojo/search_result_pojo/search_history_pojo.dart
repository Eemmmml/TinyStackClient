import 'package:json_annotation/json_annotation.dart';

part 'search_history_pojo.g.dart';

@JsonSerializable()
class SearchHistoryListPojo {
  final int code;
  final String msg;
  final List<Map<String, dynamic>> data;

  SearchHistoryListPojo({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory SearchHistoryListPojo.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryListPojoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryListPojoToJson(this);
}

@JsonSerializable()
class SearchHistoryPojo {
  final int id;
  final int userId;
  final String keyword;
  final int searchCount;
  final DateTime createTime;
  final DateTime updateTime;

  SearchHistoryPojo({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.searchCount,
    required this.createTime,
    required this.updateTime,
  });

  factory SearchHistoryPojo.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryPojoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryPojoToJson(this);
}
