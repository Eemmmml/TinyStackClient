import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/pojo/content_pojo/recommendation_video_list_pojo.dart';
import 'package:tinystack/pojo/search_result_pojo/sever_search_result_pojo.dart';
import 'package:tinystack/utils/data_format_utils.dart';

import '../../pojo/content_pojo/video_detail_pojo.dart';
import '../user_pages/profile_page_for_others.dart';

class VideoInfoPage extends StatefulWidget {
  final VideoDetailPojo videoDetail;

  const VideoInfoPage({super.key, required this.videoDetail});

  @override
  State<VideoInfoPage> createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  final dio = Dio();
  final logger = Logger();

  // 折叠状态
  bool _isExpanded = false;

  // 关注状态
  bool _isFollowed = false;

  // 视频列表
  List<RecommendationVideoListPojo> _videoList = [];
  int _currentPage = 1;
  bool _isVideoListLoading = false;
  bool _hasMore = true;
  final int _pageSize = 5;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.videoDetail.isFollowed;
    _loadInitData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitData() async {
    await _fetchVideoList(page: 1);
  }

  Future<void> _loadMoreData() async {
    if (_isVideoListLoading || !_hasMore) {
      return;
    }
    setState(() {
      _currentPage++;
      _isVideoListLoading = true;
    });

    await _fetchVideoList(page: _currentPage);

    setState(() {
      _isVideoListLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _videoList.clear();
      _hasMore = true;
    });

    await _fetchVideoList(page: _currentPage);
  }

  Future<void> _fetchVideoList({required int page}) async {
    await Future.delayed(Duration(seconds: 1));

    final response = await dio
        .get('${DioConfig.severUrl}/content/search/typed', queryParameters: {
      'type': 2,
      'pageNum': _currentPage,
      'pageSize': _pageSize,
    });

    if (response.statusCode == 200) {
      logger.d('获取视频数据列表请求成功');
      final data = ServerSearchResponsePojo.fromJson(response.data);
      if (data.code == 1) {
        logger.d('获取视频列表数据成功: ${data.data}');
        List<ServerSearchResultPojo> result = [];
        for (var map in data.data) {
          result.add(ServerSearchResultPojo.fromJson(map));
        }
        final newData = result
            .map((ServerSearchResultPojo element) =>
                RecommendationVideoListPojo.fromSearchPojo(element))
            .toList();

        setState(() {
          if (page == 1) {
            _videoList = newData;
          } else {
            _videoList.addAll(newData);
          }
          // 处理没用更多数据的情况
          _hasMore = page < 3;
          logger.d('新增 ${newData.length} 条数据');
        });
      } else {
        logger.e('获取视频列表数据失败');
      }
    } else {
      logger.e('获取视频数据列表请求失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: 各元素区域
          // UP 主信息区域
          _buildUploaderInfo(),
          // 折叠区域
          _buildCollapsibleSection(),
          const SizedBox(height: 15),
          // 占位滚动列表
          _buildVideoList(),
        ],
      ),
    );
  }

  // 构建 UP 主信息组件
  Widget _buildUploaderInfo() {
    final uploader = widget.videoDetail;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // UP 主头像
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePageForOthers(userId: widget.videoDetail.uploaderId)));
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: uploader.uploaderAvatarUrl,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 24,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => const CircleAvatar(
                radius: 24,
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const CircleAvatar(
                radius: 24,
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          // 用户信息
          Expanded(
              child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePageForOthers(userId: widget.videoDetail.uploaderId)));
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // '用户名',
                  uploader.uploaderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // '粉丝: 1.2W  作品: 34',
                  '粉丝: ${DataFormatUtils.formatNumber(uploader.fans)}  作品: ${DataFormatUtils.formatNumber(uploader.compositions)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )),

          // 关注按钮
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isFollowed = !_isFollowed;
              });
              // TODO: 实现关注取关逻辑
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              backgroundColor:
                  _isFollowed ? Colors.grey[400] : Colors.pinkAccent,
              foregroundColor: _isFollowed ? Colors.grey[600] : Colors.white,
            ),
            child: Text(
              _isFollowed ? '已关注' : '+关注',
            ),
          ),
        ],
      ),
    );
  }

  // 折叠区域组件
  Widget _buildCollapsibleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 折叠头
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
            }),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.videoDetail.title,
                        // '这是一个非常长的视频标题需要被截断处理...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '播放量：${DataFormatUtils.formatNumber(widget.videoDetail.viewCount)} 次  ${DateFormat('yyyy-MM-dd').format(widget.videoDetail.uploadTime)} 发布',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),

          // 折叠动画
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Container(),
            secondChild: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  // 展开后的详细内容
  Widget _buildExpandedContent() {
    logger.d('解析json数据: ${widget.videoDetail.tabs}');
    final jsonData = jsonDecode(widget.videoDetail.tabs);
    final List<String> tabList = [];
    for (var data in jsonData) {
      logger.d('解析数据为 $data');
      tabList.add(data as String);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          // '视频简介：这是一个非常详细的视频简介内容，用户展示视频的详细信息...',
          widget.videoDetail.description,
          style: TextStyle(color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tabList
              .map((tab) => Chip(
                    label: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                    backgroundColor: Colors.grey[100],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  // 构建视频列表
  Widget _buildVideoList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _videoList.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[300],
            indent: 16,
            endIndent: 16,
          ),
        ),
        itemBuilder: (context, index) {
          if (index >= _videoList.length) {
            // return _buildLoadingIndicator();
            return SizedBox.shrink();
          }
          return _buildVideoCard(_videoList[index]);
        },
      ),
    );
  }

  // 构建单个视频卡片组件
  Widget _buildVideoCard(RecommendationVideoListPojo video) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // TODO: 实现具体的点击逻辑
      onTap: () => debugPrint('Click ${video.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
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
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // 封面占位颜色
                        // image: DecorationImage(
                        //     image: AssetImage('assets/user_background.png'),
                        //     fit: BoxFit.cover),
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(video.coverUrl),
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
                        DataFormatUtils.formatDuration(video.durationInSecond),
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
                        // '这是一个视频标题',
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // DateFormat('yyyy-MM-dd HH:mm').format(
                        //     DateTime.now().subtract(Duration(hours: 2))),
                        DateFormat('yyyy-MM-dd HH:mm')
                            .format(video.publishTime),
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
                            // '科技评测君',
                            video.uploaderName,
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
                          // _buildInfoWithIcon(Icons.play_arrow, 120),
                          // _buildInfoWithIcon(Icons.comment, 110),
                          _buildInfoWithIcon(Icons.play_arrow, video.viewCount),
                          _buildInfoWithIcon(Icons.comment, video.commentCount),
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

  // 构建Icon和数据结合的部分
  Widget _buildInfoWithIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          NumberFormat.compact().format(count),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 格式化视频发布时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
    }
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  // 构建统计信息组件
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // TODO: 实现点击用户头像或信息跳转用户主页的逻辑
  void _handleUserProfilePage() {}
}
