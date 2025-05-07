// 排序类型枚举
import 'package:flutter/material.dart';

import '../../entity/search_result_item.dart';
import '../../entity/user_item.dart';

enum SortType { likes, comments }

class ArticleSearchResultsPage extends StatefulWidget {
  const ArticleSearchResultsPage({super.key});

  @override
  State<ArticleSearchResultsPage> createState() =>
      _ArticleSearchResultsPageState();
}

class _ArticleSearchResultsPageState extends State<ArticleSearchResultsPage> {
  List<ArticleSearchResult> _articles = [];
  SortType _currentSortType = SortType.likes;

  @override
  void initState() {
    super.initState();
    // 模拟数据
    _articles = [
      ArticleSearchResult(
        coverUrl: 'https://picsum.photos/200/200?random=8',
        avatarUrl: 'https://picsum.photos/200/200?random=1',
        uploaderName: '科技前沿',
        content: '人工智能在移动开发中的应用：最新技术趋势分析...',
        likeCount: 8911,
        commentCount: 67,
        publishTime: DateTime.now().subtract(const Duration(hours: 10)),
      ),
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
    ];

    _sortArticle();
  }

  // 用户排序
  void _sortArticle() {
    switch (_currentSortType) {
      case SortType.likes:
        _articles.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case SortType.comments:
        _articles.sort((a, b) => b.commentCount.compareTo(a.commentCount));
        break;
    }
  }

  // 切换关注状态
  void _toggleFollow(User user) {
    setState(() {
      user.isFollowing = !user.isFollowing;
    });
  }

  // 构建选择排序方式的抽屉
  Widget _buildSortDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 自定义头部高度自适应
          Container(
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
            ),
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              '排序方式',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          RadioListTile(
            title: Text('按喜欢数排序'),
            value: SortType.likes,
            groupValue: _currentSortType,
            onChanged: (value) {
              setState(() {
                _currentSortType = value!;
                _sortArticle();
              });
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: Text('按评论数排序'),
            value: SortType.comments,
            groupValue: _currentSortType,
            onChanged: (value) {
              setState(() {
                _currentSortType = value!;
                _sortArticle();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _buildSortDrawer(),
      body: Column(
        children: [
          // 自定义顶部栏
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索结果',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.sort,
                      size: 28,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              ],
            ),
          ),

          // 列表内容
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 0.8,
                  color: Colors.grey[300],
                ),
              ),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return _buildArticleCard(article);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 图文投稿卡片
  Widget _buildArticleCard(ArticleSearchResult data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            child: Image.network(
              data.coverUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: data.avatarUrl.isNotEmpty
                          ? NetworkImage(data.avatarUrl)
                          : const AssetImage(
                              'assets/user_info/user_avatar.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Text(data.uploaderName),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoWithIcon(
                        Icons.thumb_up, data.likeCount.toString()),
                    const SizedBox(width: 16),
                    _buildInfoWithIcon(
                        Icons.comment, data.commentCount.toString()),
                    const SizedBox(width: 16),
                    _buildInfoWithIcon(
                        Icons.schedule, _formatTimeAgo(data.publishTime)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建Icon和数据结合的部分
  Widget _buildInfoWithIcon(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 辅助方法
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 365) {
      return '${(difference.inDays ~/ 365)}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays ~/ 30)}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else {
      return '刚刚';
    }
  }
}
