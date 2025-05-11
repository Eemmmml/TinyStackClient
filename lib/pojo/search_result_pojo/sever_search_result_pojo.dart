import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:tinystack/entity/search_result_item.dart';

part 'sever_search_result_pojo.g.dart';

@JsonSerializable()
class ServerSearchResponsePojo {
  final int code;
  final String msg;
  final List<Map<String, dynamic>> data;

  ServerSearchResponsePojo({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory ServerSearchResponsePojo.fromJson(Map<String, dynamic> json) =>
      _$ServerSearchResponsePojoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerSearchResponsePojoToJson(this);
}

@JsonSerializable()
class ServerSearchResultPojo {
  final String? contentId;
  final String? coverUrl;
  final String? avatarUrl;
  final String? title;
  final int? uploaderId;
  final String? uploaderName;
  final int? fans;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;
  final int? type;
  final DateTime? publishTime;
  final String? ex;

  ServerSearchResultPojo(
      {this.contentId,
      this.coverUrl,
      this.avatarUrl,
      this.title,
        this.uploaderId,
      this.uploaderName,
      this.fans,
      this.viewCount,
      this.likeCount,
      this.commentCount,
      this.type,
      this.publishTime,
      this.ex});

  factory ServerSearchResultPojo.fromJson(Map<String, dynamic> json) =>
      _$ServerSearchResultPojoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerSearchResultPojoToJson(this);

  VideoSearchResult toVideoSearchResult() {
    final Map<String, dynamic> exData = jsonDecode(ex ?? '');
    return VideoSearchResult(
        coverUrl: coverUrl!,
        durationInSeconds: exData['durationInSeconds'] as int,
        title: title!,
        uploaderName: uploaderName!,
        viewCount: viewCount!,
        publishTime: publishTime!);
  }

  RelatedSearchResult toRelatedSearchResult() {
    final Map<String, dynamic> exData = jsonDecode(ex ?? '');
    final jsonData = exData['keywords'];
    final List<String> keywords = [];
    for (var data in jsonData) {
      keywords.add(data as String);
    }
    return RelatedSearchResult(keywords: keywords);
  }

  ArticleSearchResult toArticleSearchResult() {
    final Map<String, dynamic> exData = jsonDecode(ex ?? '');
    return ArticleSearchResult(
        coverUrl: coverUrl!,
        avatarUrl: avatarUrl!,
        uploaderName: uploaderName!,
        content: exData['content'] as String,
        likeCount: likeCount!,
        commentCount: commentCount!,
        publishTime: publishTime!);
  }

  UserSearchResult toUserSearchResult() {
    final Map<String, dynamic> exData = jsonDecode(ex ?? '');
    logger.d(exData['recentPosts']);
    final List<UserPost> recentPosts = [];
    for (var data in exData['recentPosts']) {
      final post = UserPost(
        coverUrl: data['coverUrl'] as String,
        title: data['title'] as String,
        views: data['views'] as int,
        publishTime:
            DateTime.fromMicrosecondsSinceEpoch(data['publishTime'] as int),
      );
      recentPosts.add(post);
    }
    return UserSearchResult(
        avatarUrl: avatarUrl!,
        uploaderName: uploaderName!,
        followerCount: exData['followerCount'] as int,
        postCount: exData['postCount'] as int,
        bio: exData['bio'] as String,
        isFollowing: exData['isFollowing'] as bool,
        recentPosts: recentPosts,
        totalPosts: recentPosts.length);
  }
}
