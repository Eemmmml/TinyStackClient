// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultSearchPojo _$ResultSearchPojoFromJson(Map<String, dynamic> json) =>
    ResultSearchPojo(
      coverUrl: json['coverUrl'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      title: json['title'] as String?,
      uploaderName: json['uploaderName'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt(),
      type: (json['type'] as num).toInt(),
      publishTime: json['publishTime'] == null
          ? null
          : DateTime.parse(json['publishTime'] as String),
      ex: json['ex'] as String?,
    );

Map<String, dynamic> _$ResultSearchPojoToJson(ResultSearchPojo instance) =>
    <String, dynamic>{
      'coverUrl': instance.coverUrl,
      'avatarUrl': instance.avatarUrl,
      'title': instance.title,
      'uploaderName': instance.uploaderName,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'publishTime': instance.publishTime?.toIso8601String(),
      'type': instance.type,
      'ex': instance.ex,
    };

VideoSearchResult _$VideoSearchResultFromJson(Map<String, dynamic> json) =>
    VideoSearchResult(
      coverUrl: json['coverUrl'] as String,
      durationInSeconds: (json['durationInSeconds'] as num).toInt(),
      title: json['title'] as String,
      uploaderName: json['uploaderName'] as String,
      viewCount: (json['viewCount'] as num).toInt(),
      publishTime: DateTime.parse(json['publishTime'] as String),
    );

Map<String, dynamic> _$VideoSearchResultToJson(VideoSearchResult instance) =>
    <String, dynamic>{
      'coverUrl': instance.coverUrl,
      'durationInSeconds': instance.durationInSeconds,
      'title': instance.title,
      'uploaderName': instance.uploaderName,
      'viewCount': instance.viewCount,
      'publishTime': instance.publishTime.toIso8601String(),
    };

RelatedSearchResult _$RelatedSearchResultFromJson(Map<String, dynamic> json) =>
    RelatedSearchResult(
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RelatedSearchResultToJson(
        RelatedSearchResult instance) =>
    <String, dynamic>{
      'keywords': instance.keywords,
    };

ArticleSearchResult _$ArticleSearchResultFromJson(Map<String, dynamic> json) =>
    ArticleSearchResult(
      contentId: json['contentId'] as String? ?? '',
      coverUrl: json['coverUrl'] as String,
      avatarUrl: json['avatarUrl'] as String,
      uploaderName: json['uploaderName'] as String,
      content: json['content'] as String,
      likeCount: (json['likeCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      publishTime: DateTime.parse(json['publishTime'] as String),
    );

Map<String, dynamic> _$ArticleSearchResultToJson(
        ArticleSearchResult instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'coverUrl': instance.coverUrl,
      'avatarUrl': instance.avatarUrl,
      'uploaderName': instance.uploaderName,
      'content': instance.content,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'publishTime': instance.publishTime.toIso8601String(),
    };

UserSearchResult _$UserSearchResultFromJson(Map<String, dynamic> json) =>
    UserSearchResult(
      avatarUrl: json['avatarUrl'] as String,
      uploaderName: json['uploaderName'] as String,
      followerCount: (json['followerCount'] as num).toInt(),
      postCount: (json['postCount'] as num).toInt(),
      bio: json['bio'] as String,
      isFollowing: json['isFollowing'] as bool,
      recentPosts: (json['recentPosts'] as List<dynamic>)
          .map((e) => UserPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPosts: (json['totalPosts'] as num).toInt(),
    );

Map<String, dynamic> _$UserSearchResultToJson(UserSearchResult instance) =>
    <String, dynamic>{
      'avatarUrl': instance.avatarUrl,
      'uploaderName': instance.uploaderName,
      'followerCount': instance.followerCount,
      'postCount': instance.postCount,
      'bio': instance.bio,
      'isFollowing': instance.isFollowing,
      'recentPosts': instance.recentPosts,
      'totalPosts': instance.totalPosts,
    };

UserPost _$UserPostFromJson(Map<String, dynamic> json) => UserPost(
      coverUrl: json['coverUrl'] as String,
      title: json['title'] as String,
      views: (json['views'] as num).toInt(),
      publishTime: DateTime.parse(json['publishTime'] as String),
    );

Map<String, dynamic> _$UserPostToJson(UserPost instance) => <String, dynamic>{
      'coverUrl': instance.coverUrl,
      'title': instance.title,
      'views': instance.views,
      'publishTime': instance.publishTime.toIso8601String(),
    };
