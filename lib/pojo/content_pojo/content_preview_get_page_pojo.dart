import 'package:json_annotation/json_annotation.dart';
import 'package:tinystack/entity/content_preview_item.dart';

part 'content_preview_get_page_pojo.g.dart';

@JsonSerializable()
class ContentPreviewGetPagePojo {
  final int code;
  final String msg;
  final List<ContentPreviewItem> data;

  ContentPreviewGetPagePojo({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory ContentPreviewGetPagePojo.fromJson(Map<String, dynamic> json) => _$ContentPreviewGetPagePojoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentPreviewGetPagePojoToJson(this);
}
