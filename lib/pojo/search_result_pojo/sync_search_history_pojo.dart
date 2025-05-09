import 'package:json_annotation/json_annotation.dart';

part 'sync_search_history_pojo.g.dart';

@JsonSerializable()
class SyncSearchHistoryPojo {
  final int code;
  final String msg;
  final bool data;

  SyncSearchHistoryPojo({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory SyncSearchHistoryPojo.fromJson(Map<String, dynamic> json) =>
      _$SyncSearchHistoryPojoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncSearchHistoryPojoToJson(this);
}
