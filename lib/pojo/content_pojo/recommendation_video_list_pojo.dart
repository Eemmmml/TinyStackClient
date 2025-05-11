import 'package:json_annotation/json_annotation.dart';
import 'package:tinystack/entity/search_result_item.dart';
import 'package:tinystack/pojo/search_result_pojo/sever_search_result_pojo.dart';

part 'recommendation_video_list_pojo.g.dart';

@JsonSerializable()
class RecommendationVideoListPojo {
  // 数据 id
  final int id;

  // 视频内容 id
  final int videoContentId;

  // 视频标题
  final String title;

  // 视频作者 id
  final int uploaderId;

  // 视频作者用户名
  final String uploaderName;

  // 视频封面 url
  final String coverUrl;

  // 视频评论数
  final int commentCount;

  // 视频播放量
  final int viewCount;

  // 视频时长
  final int durationInSecond;

  final DateTime publishTime;

  RecommendationVideoListPojo({
    required this.id,
    required this.videoContentId,
    required this.title,
    required this.uploaderId,
    required this.uploaderName,
    required this.coverUrl,
    required this.commentCount,
    required this.viewCount,
    required this.durationInSecond,
    required this.publishTime,
  });

  factory RecommendationVideoListPojo.fromJson(Map<String, dynamic> json) =>
      _$RecommendationVideoListPojoFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationVideoListPojoToJson(this);

  factory RecommendationVideoListPojo.fromSearchPojo(
      ServerSearchResultPojo searchResult) {
    VideoSearchResult video = searchResult.toVideoSearchResult();

    return RecommendationVideoListPojo(
      id: int.parse(searchResult.contentId!),
      videoContentId: int.parse(searchResult.contentId!),
      title: video.title,
      uploaderId: searchResult.uploaderId!,
      uploaderName: video.uploaderName,
      coverUrl: video.coverUrl,
      commentCount: searchResult.commentCount!,
      viewCount: video.viewCount,
      durationInSecond: video.durationInSeconds,
      publishTime: video.publishTime,
    );
  }
}
