import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/pojo/search_result_pojo/sever_search_result_pojo.dart';

part 'search_result_item.g.dart';

enum SearchResultType {
  video,
  article,
  user,
  related,
}

// 数据模型基类
abstract class SearchResultItem {
  final SearchResultType type;

  SearchResultItem({required this.type});
}

@JsonSerializable()
class ResultSearchPojo {
  // 封面图片 url 地址
  final String? coverUrl;

  // 作品上传者头像
  final String? avatarUrl;

  // 作品标题
  final String? title;

  // 作品上传者名称
  final String? uploaderName;

  // 内容访问次数
  final int? viewCount;

  // 内容点赞数
  final int? likeCount;

  // 内容评论数
  final int? commentCount;

  // 内容发表时间
  final DateTime? publishTime;

  /*
    内容类型:
      0 表示 搜索相关结果
      1 表示 图文结果
      2 表示 视频结果
      3 表示 用户结果
   */

  final int type;

  // 用来存储一些扩展字段的 Json 数据
  final String? ex;

  ResultSearchPojo({
    this.coverUrl,
    this.avatarUrl,
    this.title,
    this.uploaderName,
    this.viewCount,
    this.likeCount,
    this.commentCount,
    required this.type,
    this.publishTime,
    this.ex,
  });

  factory ResultSearchPojo.fromJson(Map<String, dynamic> json) =>
      _$ResultSearchPojoFromJson(json);

  Map<String, dynamic> toJson() => _$ResultSearchPojoToJson(this);
}

// 视频卡片数据模型
@JsonSerializable()
class VideoSearchResult extends SearchResultItem {
  final String coverUrl;
  final int durationInSeconds;
  final String title;
  final String uploaderName;
  final int viewCount;
  final DateTime publishTime;

  VideoSearchResult({
    required this.coverUrl,
    required this.durationInSeconds,
    required this.title,
    required this.uploaderName,
    required this.viewCount,
    required this.publishTime,
  }) : super(type: SearchResultType.video);

  factory VideoSearchResult.fromJson(Map<String, dynamic> json) =>
      _$VideoSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSearchResultToJson(this);

  ServerSearchResultPojo toServerSearchPojo() {
    final ex = jsonEncode({"durationInSeconds": durationInSeconds});
    return ServerSearchResultPojo(
      contentId: '',
      coverUrl: coverUrl,
      avatarUrl: '',
      title: title,
      uploaderName: uploaderName,
      viewCount: viewCount,
      likeCount: 0,
      commentCount: 0,
      type: 2,
      publishTime: publishTime,
      ex: ex,
    );
  }
}

// 相关搜索卡片数据模型
@JsonSerializable()
class RelatedSearchResult extends SearchResultItem {
  final List<String> keywords;

  RelatedSearchResult({
    required this.keywords,
  }) : super(type: SearchResultType.related);

  factory RelatedSearchResult.fromJson(Map<String, dynamic> json) =>
      _$RelatedSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$RelatedSearchResultToJson(this);

  ServerSearchResultPojo toServerSearchPojo() {
    Map<String, dynamic> json = {"keywords": keywords};
    final ex = jsonEncode(json);
    return ServerSearchResultPojo(
      contentId: '',
      coverUrl: '',
      avatarUrl: '',
      title: '',
      uploaderName: '',
      viewCount: 0,
      likeCount: 0,
      commentCount: 0,
      type: 0,
      publishTime: null,
      ex: ex,
    );
  }
}

// 图文投稿卡片数据模型
@JsonSerializable()
class ArticleSearchResult extends SearchResultItem {
  final String contentId;
  final String coverUrl;
  final String avatarUrl;
  final String uploaderName;

  // 在搜索用实体对象中的 ex 字段中存储
  final String content;
  final int likeCount;
  final int commentCount;
  final DateTime publishTime;

  ArticleSearchResult({
    this.contentId = '',
    required this.coverUrl,
    required this.avatarUrl,
    required this.uploaderName,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.publishTime,
  }) : super(type: SearchResultType.article);

  factory ArticleSearchResult.fromJson(Map<String, dynamic> json) =>
      _$ArticleSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleSearchResultToJson(this);

  ServerSearchResultPojo toSeverSearchPojo() {
    Map<String, dynamic> json = {"content": content};
    final ex = jsonEncode(json);
    return ServerSearchResultPojo(
      contentId: '',
      coverUrl: coverUrl,
      avatarUrl: avatarUrl,
      title: '',
      uploaderName: uploaderName,
      viewCount: 0,
      likeCount: likeCount,
      commentCount: commentCount,
      type: 1,
      publishTime: publishTime,
      ex: ex,
    );
  }
}

// 用户结果卡片模型
@JsonSerializable()
class UserSearchResult extends SearchResultItem {
  final String avatarUrl;
  final String uploaderName;

  // 下面的数据在搜索实体中的 ex 字段中用 json 字符串来存储，需要注意序列化
  final int followerCount;
  final int postCount;
  final String bio;
  bool isFollowing;
  final List<UserPost> recentPosts;
  final int totalPosts;

  UserSearchResult({
    required this.avatarUrl,
    required this.uploaderName,
    required this.followerCount,
    required this.postCount,
    required this.bio,
    required this.isFollowing,
    required this.recentPosts,
    required this.totalPosts,
  }) : super(type: SearchResultType.user);

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$UserSearchResultToJson(this);

  ServerSearchResultPojo toServerSearchPojo() {
    Map<String, dynamic> json = {
      "followerCount": followerCount,
      "postCount": postCount,
      "bio": bio,
      "isFollowing": isFollowing,
      "recentPosts": recentPosts,
    };
    final ex = jsonEncode(json);
    return ServerSearchResultPojo(
      contentId: '',
      coverUrl: '',
      avatarUrl: avatarUrl,
      title: '',
      uploaderName: uploaderName,
      viewCount: 0,
      likeCount: 0,
      commentCount: 0,
      type: 3,
      ex: ex,
    );
  }
}

// 用户投稿数据模型
@JsonSerializable()
class UserPost {
  final String coverUrl;
  final String title;
  final int views;
  final DateTime publishTime;

  UserPost(
      {required this.coverUrl,
      required this.title,
      required this.views,
      required this.publishTime});

  factory UserPost.fromJson(Map<String, dynamic> json) =>
      _$UserPostFromJson(json);

  Map<String, dynamic> toJson() => _$UserPostToJson(this);
}

final mockSearchResults = [
  // 视频卡片
  VideoSearchResult(
    title: 'Flutter开发实战：从零构建社交媒体应用教程',
    coverUrl: "https://picsum.photos/200/300?random=1",
    durationInSeconds: 3542,
    uploaderName: "技术小咖",
    viewCount: 12543,
    publishTime: DateTime.now().subtract(const Duration(hours: 5)),
  ),

  // 相关搜索卡片
  RelatedSearchResult(keywords: [
    'Flutter教程',
    '社交媒体设计',
    '2023 UI趋势',
    '移动端开发',
    'Firebase集成',
    '状态管理',
    '动画效果',
    '性能优化'
  ]),

  // 图文投稿卡片
  ArticleSearchResult(
    coverUrl: 'https://picsum.photos/200/200?random=2',
    avatarUrl: 'https://picsum.photos/200/200?random=1',
    uploaderName: '设计达人',
    content: '深度解析Material 3设计规范：如何打造现代化的应用界面...',
    likeCount: 2345,
    commentCount: 156,
    publishTime: DateTime.now().subtract(const Duration(days: 2)),
  ),

  // 用户卡片
  UserSearchResult(
    avatarUrl: 'https://picsum.photos/100/100?random=3',
    uploaderName: '移动开发老张',
    followerCount: 12890,
    postCount: 56,
    bio: '专注Flutter和移动端开发技术分享，定期发布实战教程',
    isFollowing: false,
    totalPosts: 56,
    recentPosts: [
      UserPost(
          coverUrl: 'https://picsum.photos/120/90?random=4',
          title: 'Flutter状态管理终极指南',
          views: 8904,
          publishTime: DateTime.now().subtract(const Duration(days: 3))),
      UserPost(
          coverUrl: 'https://picsum.photos/120/90?random=5',
          title: 'Firebase集成实战',
          views: 5678,
          publishTime: DateTime.now().subtract(const Duration(days: 7))),
      UserPost(
          coverUrl: 'https://picsum.photos/120/90?random=6',
          title: '动画效果实现技巧',
          views: 3456,
          publishTime: DateTime.now().subtract(const Duration(days: 15))),
    ],
  ),

  // 更多测试数据...
  VideoSearchResult(
      title: '十分钟学会Dart语言基础语法',
      coverUrl: 'https://picsum.photos/200/300?random=7',
      durationInSeconds: 623,
      uploaderName: '编程速成班',
      viewCount: 8921,
      publishTime: DateTime.now().subtract(const Duration(days: 1))),

  ArticleSearchResult(
    coverUrl: 'https://picsum.photos/200/200?random=8',
    avatarUrl: 'https://picsum.photos/200/200?random=1',
    uploaderName: '科技前沿',
    content: '人工智能在移动开发中的应用：最新技术趋势分析...',
    likeCount: 891,
    commentCount: 67,
    publishTime: DateTime.now().subtract(const Duration(hours: 10)),
  ),

// 新增视频卡片（含长标题测试）
  VideoSearchResult(
    title: 'Flutter状态管理终极指南：Riverpod与Provider深度对比',
    coverUrl: "https://picsum.photos/200/300?random=9",
    durationInSeconds: 4287,
    uploaderName: "架构师之路",
    viewCount: 23456,
    publishTime: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
  ),

// 新增用户卡片（企业账号）
  UserSearchResult(
    avatarUrl: 'https://picsum.photos/100/100?random=10',
    uploaderName: 'Google Flutter团队',
    followerCount: 356789,
    postCount: 128,
    bio: '官方Flutter技术团队，分享最新框架特性与开发实践',
    isFollowing: true,
    totalPosts: 128,
    recentPosts: [
      UserPost(
          coverUrl: 'https://picsum.photos/120/90?random=11',
          title: 'Flutter 3.0新特性解析',
          views: 15678,
          publishTime: DateTime.now().subtract(const Duration(hours: 6))),
      UserPost(
          coverUrl: 'https://picsum.photos/120/90?random=12',
          title: 'Dart 3.0空安全最佳实践',
          views: 9876,
          publishTime: DateTime.now().subtract(const Duration(days: 2))),
    ],
  ),

// 新增图文卡片（技术解析）
  ArticleSearchResult(
    coverUrl: 'https://picsum.photos/200/200?random=13',
    avatarUrl: 'https://picsum.photos/200/200?random=14',
    uploaderName: '全栈工程师',
    content: 'Flutter Web与React Native性能对比：跨平台框架的终极对决...',
    likeCount: 1567,
    commentCount: 89,
    publishTime: DateTime.now().subtract(const Duration(days: 5)),
  ),

// 新增相关搜索卡片（扩展关键词）
  RelatedSearchResult(keywords: [
    'Flutter性能优化',
    'Dart空安全',
    '跨平台开发',
    'UI动画实现',
    '热重载原理',
    '包体积压缩',
    '混合开发方案',
    'CI/CD集成'
  ]),

// 新增视频卡片（短视频场景）
  VideoSearchResult(
    title: '3分钟学会Flutter弹幕效果',
    coverUrl: "https://picsum.photos/200/300?random=15",
    durationInSeconds: 182,
    uploaderName: "动效实验室",
    viewCount: 8765,
    publishTime: DateTime.now().subtract(const Duration(minutes: 45)),
  ),

// 新增用户卡片（个人开发者）
  UserSearchResult(
    avatarUrl: 'https://picsum.photos/100/100?random=16',
    uploaderName: '独立开发者小王',
    followerCount: 1234,
    postCount: 23,
    bio: '分享个人项目开发经验与Flutter小技巧',
    isFollowing: false,
    totalPosts: 23,
    recentPosts: [
      UserPost(
          coverUrl: 'https://picsum.photos/120/90?random=17',
          title: 'Flutter桌面端开发实践',
          views: 2345,
          publishTime: DateTime.now().subtract(const Duration(days: 9))),
    ],
  ),

// 新增图文卡片（设计规范）
  ArticleSearchResult(
    coverUrl: 'https://picsum.photos/200/200?random=18',
    avatarUrl: 'https://picsum.photos/200/200?random=19',
    uploaderName: 'UX设计狮',
    content: 'Material Design 3在Flutter中的完整实现方案：从颜色系统到组件定制...',
    likeCount: 892,
    commentCount: 45,
    publishTime: DateTime.now().subtract(const Duration(hours: 18)),
  ),

// 新增长文本测试项
  VideoSearchResult(
    title: '这是一条超长标题测试数据用于验证UI布局的适应性：Flutter在复杂列表场景下的性能优化与内存管理深度解析（含实战案例）',
    coverUrl: "https://picsum.photos/200/300?random=20",
    durationInSeconds: 6543,
    uploaderName: "性能优化专家",
    viewCount: 34521,
    publishTime: DateTime.now().subtract(const Duration(days: 30)),
  ),
];

final logger = Logger();
final dio = Dio();

Future<List<SearchResultItem>> fetchSearchData({required int page, required int pageSize, required String keyword}) async {
  logger.d('开始获取搜索数据，搜索关键字: $keyword');
  final response = await dio.get('${DioConfig.severUrl}/content/search', queryParameters: {"pageNum": page, "pageSize": pageSize, "keyword": keyword});
  final List<SearchResultItem> newData = [];
  if (response.statusCode == 200) {
    logger.d('获取搜索数据请求成功, 开始解析数据');
    final jsonData = ServerSearchResponsePojo.fromJson(response.data);
    if (jsonData.code == 1) {
      logger.d('成功获取搜索数据');
      for (var data in jsonData.data) {
        final tempData = ServerSearchResultPojo.fromJson(data);
        switch (tempData.type) {
          case 0:
            newData.add(tempData.toRelatedSearchResult());
            break;
          case 1:
            newData.add(tempData.toArticleSearchResult());
            break;
          case 2:
            newData.add(tempData.toVideoSearchResult());
            break;
          case 3:
            newData.add(tempData.toUserSearchResult());
            break;
          default:
            logger.d('数据错误，请查看后台数据: type ${tempData.type}');
            break;
        }
      }
    } else {
      logger.e('获取搜索数据失败');
    }
  } else {
    logger.e('获取搜索数据请求失败');
  }
  return newData;
}