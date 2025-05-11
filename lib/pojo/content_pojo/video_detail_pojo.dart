import 'package:json_annotation/json_annotation.dart';

part 'video_detail_pojo.g.dart';

@JsonSerializable()
class VideoDetailPojo {
  // 数据 ID
  final int id;
  // 视频发布者 ID
  final int uploaderId;
  // 视频发布者名称
  final String uploaderName;
  // 视频发布者头像资源路径
  final String uploaderAvatarUrl;
  // 视频发布者的粉丝数
  final int fans;
  // 视频发布者的作品数
  final int compositions;
  // 当前用户是否关注了视频上传者
  final bool isFollowed;
  // 当前视频的标题
  final String title;
  // 当前视频的播放资源
  final String videoSource;
  // 当前视频的简介
  final String description;
  // 当前视频的播放量
  final int viewCount;
  // 当前视频的评论数
  final int commentCount;
  // 视频关键字列表
  final String tabs;
  // 当前视频的发布时间
  final DateTime uploadTime;

  VideoDetailPojo({
    required this.id,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploaderAvatarUrl,
    required this.fans,
    required this.compositions,
    required this.isFollowed,
    required this.title,
    required this.videoSource,
    required this.viewCount,
    required this.commentCount,
    required this.tabs,
    required this.description,
    required this.uploadTime,
});

  factory VideoDetailPojo.fromJson(Map<String, dynamic> json) => _$VideoDetailPojoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoDetailPojoToJson(this);
}