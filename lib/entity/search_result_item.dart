// 数据模型基类
abstract class SearchResultItem {
  final String type;

  SearchResultItem({required this.type});
}

// 视频卡片数据模型
class VideoSearchResult extends SearchResultItem {
  final String coverUrl;
  final int durationInSeconds;
  final String title;
  final String upName;
  final int viewCount;
  final DateTime publishTime;

  VideoSearchResult({
    required this.coverUrl,
    required this.durationInSeconds,
    required this.title,
    required this.upName,
    required this.viewCount,
    required this.publishTime,
  }) : super(type: 'video');
}

// 相关搜索卡片数据模型
class RelatedSearchResult extends SearchResultItem {
  final List<String> keywords;

  RelatedSearchResult({
    required this.keywords,
  }) : super(type: 'related');
}

// 图文投稿卡片数据模型
class ArticleSearchResult extends SearchResultItem {
  final String coverUrl;
  final String avatarUrl;
  final String username;
  final String content;
  final int likeCount;
  final int commentCount;
  final DateTime publishTime;

  ArticleSearchResult({
    required this.coverUrl,
    required this.avatarUrl,
    required this.username,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.publishTime,
  }) : super(type: 'article');
}

// 用户结果卡片模型
class UserSearchResult extends SearchResultItem {
  final String avatarUrl;
  final String username;
  final int followerCount;
  final int postCount;
  final String bio;
  final bool isFollowing;
  final List<UserPost> recentPosts;
  final int totalPosts;

  UserSearchResult({
    required this.avatarUrl,
    required this.username,
    required this.followerCount,
    required this.postCount,
    required this.bio,
    required this.isFollowing,
    required this.recentPosts,
    required this.totalPosts,
  }) : super(type: 'user');
}

// 用户投稿数据模型
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
}

final mockSearchResults = [
  // 视频卡片
  VideoSearchResult(
    title: 'Flutter开发实战：从零构建社交媒体应用教程',
    coverUrl: "https://picsum.photos/200/300?random=1",
    durationInSeconds: 3542,
    upName: "技术小咖",
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
    username: '设计达人',
    content: '深度解析Material 3设计规范：如何打造现代化的应用界面...',
    likeCount: 2345,
    commentCount: 156,
    publishTime: DateTime.now().subtract(const Duration(days: 2)),
  ),

  // 用户卡片
  UserSearchResult(
    avatarUrl: 'https://picsum.photos/100/100?random=3',
    username: '移动开发老张',
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
      upName: '编程速成班',
      viewCount: 8921,
      publishTime: DateTime.now().subtract(const Duration(days: 1))),

  ArticleSearchResult(
    coverUrl: 'https://picsum.photos/200/200?random=8',
    avatarUrl: 'https://picsum.photos/200/200?random=1',
    username: '科技前沿',
    content: '人工智能在移动开发中的应用：最新技术趋势分析...',
    likeCount: 891,
    commentCount: 67,
    publishTime: DateTime.now().subtract(const Duration(hours: 10)),
  ),
];
