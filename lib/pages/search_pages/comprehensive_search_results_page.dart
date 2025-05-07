import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/pojo/search_result_pojo/sever_search_result_pojo.dart';

import '../../entity/search_result_item.dart';

class ComprehensiveSearchResultsPage extends StatefulWidget {
  // 混合类型搜索结果列表
  final String keyword;
  // final List<SearchResultItem>? initialResults;

  const ComprehensiveSearchResultsPage(
      {super.key, required this.keyword});

  @override
  State<ComprehensiveSearchResultsPage> createState() =>
      _ComprehensiveSearchResultsPageState();
}

class _ComprehensiveSearchResultsPageState
    extends State<ComprehensiveSearchResultsPage> {
  // 页面滚动控制器
  late ScrollController _scrollController;

  // 日志工具
  final logger = Logger();

  // 互联网请求工具
  final dio = Dio();

  // 加载状态
  bool _isLoading = false;

  // 是否有更多数据
  bool _hasMore = true;

  // 当前页面
  int _currentPage = 1;

  // 每个页面的搜索结果数
  final int _itemsPerPage = 10;

  // 搜索结果列表
  List<SearchResultItem> _searchResults = [];

  // // 管理关注状态
  // late bool _isFollowing;

  // 下方图标按钮尺寸
  final double _iconButtonSize = 20;

  @override
  void initState() {
    // TODO: 从后台初始化关注状态
    // _isFollowing = true;
    // _searchResults = _fetchData(page: 1, pageSize: _itemsPerPage, keyword: widget.keyword);
    _loadNewData();
    // _searchResults = widget.initialResults ?? [];
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听器
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && _hasMore) {
      _loadMoreData();
    }
  }

  // 加载新的的数据
  Future<void> _loadNewData() async {
    setState(() {
      _isLoading = true;
    });
    // TODO: 替换为实际的网络请求数据
    // 模拟加载时的网络延迟
    await Future.delayed(Duration(seconds: 2));

    // final newData = await _mockFetchData(page: 1);
    final newData = await _fetchData(page: 1, pageSize: _itemsPerPage, keyword: widget.keyword);

    setState(() {
      _searchResults = newData;
      _currentPage = 1;
      _hasMore = newData.length == _itemsPerPage;
      _isLoading = false;
    });
  }

  // 加载更多的数据
  Future<void> _loadMoreData() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: 替换为实际的网络请求数据
    // 模拟加载时的网络延迟
    await Future.delayed(Duration(seconds: 2));

    // final newData = await _mockFetchData(page: _currentPage + 1);

    final newData = await _fetchData(page: _currentPage + 1, pageSize: _itemsPerPage, keyword: widget.keyword);

    setState(() {
      _searchResults.addAll(newData);
      _currentPage++;
      _hasMore = newData.length == _itemsPerPage;
      _isLoading = false;
    });
  }

  Future<List<SearchResultItem>> _mockFetchData({required int page}) async {
    // 模拟分页数据
    final start = (page - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;

    await Future.delayed(Duration(milliseconds: 500));

    if (start >= mockSearchResults.length) return [];

    return mockSearchResults.sublist(start, end.clamp(0, mockSearchResults.length));
  }

  Future<List<SearchResultItem>> _fetchData({required int page, required int pageSize, required String keyword}) async {
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

  // 处理关注状态切换
  void _toggleFollow(UserSearchResult data) {
    setState(() {
      // _isFollowing = !_isFollowing;
      data.isFollowing = !data.isFollowing;
    });
    // TODO: 这里添加网络请求同步数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadNewData,
        color: Colors.pinkAccent,
        displacement: 40,
        strokeWidth: 2.5,
        edgeOffset: 20,
        child:    ListView.separated(
          controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _searchResults.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _searchResults.length) {
                return _buildLoadingIndicator();
              }

              final item = _searchResults[index];
              if (item == null) return const SizedBox.shrink();
              Widget card;
              switch (item.type) {
                case SearchResultType.video:
                  card = _buildVideoCard(item as VideoSearchResult);
                  break;
                case SearchResultType.related:
                  card = _buildRelatedSearchCard(item as RelatedSearchResult);
                  break;
                case SearchResultType.article:
                  card = _buildArticleCard(item as ArticleSearchResult);
                  break;
                case SearchResultType.user:
                  card = _buildUserCard(item as UserSearchResult);
                  break;
                // default:
                //   card = const SizedBox(height: 1);
              }
              return card;
            },
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                thickness: 0.8,
                color: Colors.grey[300],
              ),
            ),
          ),
      ),
    );
  }

  // 构建加载页面
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: _hasMore ? const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.pinkAccent,
          ),
        ) : const Text(
          '没有更多内容了',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 构建单个视频卡片组件
  Widget _buildVideoCard(VideoSearchResult data) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // TODO: 实现具体的点击逻辑
      onTap: () => debugPrint('Click ex'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 视频封面部分
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 150,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // 封面占位颜色
                        image: DecorationImage(
                            // image: NetworkImage(data.coverUrl),
                          image: CachedNetworkImageProvider(
                            data.coverUrl,
                            maxWidth: 150,
                            maxHeight: 120,
                          ),
                            fit: BoxFit.cover),
                      ),
                      // TODO: 从网络获取图片
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(data.durationInSeconds),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(
                            DateTime.now().subtract(Duration(hours: 2))),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 5),
                      // UP 主信息行
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            data.uploaderName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoWithIcon(
                              Icons.play_arrow, data.viewCount.toString()),
                          _buildInfoWithIcon(
                              Icons.schedule, _formatTimeAgo(data.publishTime)),
                          IconButton(
                            icon: Icon(Icons.more_vert, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              // TODO: 实现按钮交互逻辑
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 搜索相关卡片
  Widget _buildRelatedSearchCard(RelatedSearchResult data) {
    if (data.keywords.isEmpty) return const SizedBox.shrink();
    final keywords = data.keywords.take(8).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '相关搜索',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4.5,
                mainAxisSpacing: 4,
                crossAxisSpacing: 14,
              ),
              itemCount: keywords.length,
              itemBuilder: (context, index) =>
                  _buildClickableKeyword(keywords[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableKeyword(String keyword) {
    return InkWell(
      onTap: () {
        // TODO: 实现点击逻辑
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          keyword,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
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
            // child: Image.network(
            //   data.coverUrl,
            //   width: 100,
            //   height: 100,
            //   fit: BoxFit.cover,
            //   errorBuilder: (_, __, ___) => Container(
            //     width: 100,
            //     height: 100,
            //     color: Colors.grey,
            //   ),
            // ),
            child: CachedNetworkImage(
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              imageUrl: data.coverUrl,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: Icon(Icons.error),
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
                      // backgroundImage: data.avatarUrl.isNotEmpty
                      //     ? NetworkImage(data.avatarUrl)
                      //     : const AssetImage(
                      //         'assets/user_info/user_avatar.jpg'),
                      backgroundImage: data.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(data.avatarUrl)
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

  // 用户卡片
  Widget _buildUserCard(UserSearchResult data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户基本信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 3),
                    CircleAvatar(
                      radius: 28,
                      // backgroundImage: NetworkImage(data.avatarUrl),
                      backgroundImage: CachedNetworkImageProvider(data.avatarUrl),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.uploaderName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${data.followerCount}粉丝  ${data.postCount}投稿',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        data.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 实现按钮点击逻辑
                        _toggleFollow(data);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(80, 24),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        backgroundColor:
                            data.isFollowing ? Colors.grey : Colors.pinkAccent,
                      ),
                      child: data.isFollowing
                          ? Text('已关注',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[400]))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                const SizedBox(width: 1),
                                Text('关注',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white))
                              ],
                            ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.topCenter,
                      iconSize: _iconButtonSize,
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // TODO: 实现按钮点击逻辑
                        setState(() {
                          data.isFollowing = !data.isFollowing;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            // 用户投稿预览
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: data.recentPosts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) =>
                    _buildUserPostCard(data.recentPosts[index]),
              ),
            ),

            // 查看全部投稿
            TextButton(
              onPressed: () {
                // TODO: 实现按钮点击逻辑
                _toggleFollow(data);
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('查看全部${data.totalPosts}投稿'),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建用户投稿卡片
  Widget _buildUserPostCard(UserPost post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image.network(post.coverUrl,
                //     width: 120, height: 90, fit: BoxFit.cover),
                CachedNetworkImage(
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                  imageUrl: post.coverUrl,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey,
                    child: Icon(Icons.broken_image),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0.7),
                            Colors.transparent,
                          ]),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow,
                            color: Colors.white, size: 12),
                        Text('${post.views}',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 35,
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Text(
              _formatTimeAgo(post.publishTime),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
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
