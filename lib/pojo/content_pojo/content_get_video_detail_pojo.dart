import 'package:json_annotation/json_annotation.dart';

part 'content_get_video_detail_pojo.g.dart';

@JsonSerializable()
class ContentGetVideoDetailPojo {
  final int code;
  final String msg;
  final Map<String, dynamic> data;

  ContentGetVideoDetailPojo({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory ContentGetVideoDetailPojo.fromJson(Map<String, dynamic> json) =>
      _$ContentGetVideoDetailPojoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentGetVideoDetailPojoToJson(this);
}
