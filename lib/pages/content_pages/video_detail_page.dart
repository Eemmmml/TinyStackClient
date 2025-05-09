import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/pojo/content_pojo/content_get_video_detail_pojo.dart';
import 'package:tinystack/pojo/content_pojo/video_detail_pojo.dart';
import 'package:tinystack/provider/auth_state_provider.dart';
import 'package:video_player/video_player.dart';

import 'comment_page.dart';
import 'video_info_page.dart';

// TODO: 需要实现从后端获取视频资源路径，和视频播放如上次播放进度等基本数据
class VideoDetailPage extends StatefulWidget {
  final int videoContentId;

  // final int userId;

  const VideoDetailPage({super.key, required this.videoContentId});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  final logger = Logger();
  final dio = Dio();
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  static const double kScrollThreshold = 50; // 滑动阈值，可根据需要调整

  // 加载状态管理变量
  bool _isLoading = true;

  // 视频数据实体
  VideoDetailPojo? _videoDetail;

  // 错误信息
  String? _errorMessage;

  // 是否全屏
  bool _isFullScreen = false;

  // 是否显示控制组件
  bool _showControls = true;

  // 计时器,用来计时自动隐藏视频控制按钮
  Timer? _hideControlsTimer;

  // 页面滚动控制器
  final ScrollController _scrollController = ScrollController();

  // AppBar 的透明度
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    // _loadVideoData();
  }

  void _handleVideoPlayerListener() {
    if (_videoPlayerController.value.isInitialized && mounted) {
      setState(() {});
    }
  }

  // 加载视频数据
  Future<void> _loadVideoData() async {
    try {
      // 模拟获取到的视频数据 - 实际应从网络请求获取
      // final mockData = VideoDetailPojo(
      //   id: widget.videoContentId,
      //   uploaderId: 1,
      //   uploaderName: '测试用户',
      //   uploaderAvatarUrl:
      //       'https://tinystack-image-store-1356865752.cos.ap-beijing.myqcloud.com/tiny_stack_video_thumbnail_chat_user_123_1746204092903',
      //   fans: 1000,
      //   compositions: 50,
      //   isFollowed: false,
      //   title: '测试视频标题',
      //   videoSource:
      //       'https://tinystack-video-store-1356865752.cos.ap-beijing.myqcloud.com/tiny_stack_shot_video_chat_user_123_1746198664053',
      //   viewCount: 5000,
      //   tabs: ['测试', '视频'],
      //   description: '这是一个测试视频描述',
      //   uploadTime: DateTime.now(),
      // );

      final provider = Provider.of<AuthStateProvider>(context, listen: false);

      final response = await dio
          .get('${DioConfig.severUrl}/content/video', queryParameters: {
        'userId': provider.isLoggedInID,
        'videoId': widget.videoContentId,
      });

      final VideoDetailPojo? pojo;
      if (response.statusCode == 200) {
        logger.d('视频数据加载请求成功: ${response.data}');
        final data = ContentGetVideoDetailPojo.fromJson(response.data);
        if (data.code == 1) {
          logger.d('获取视频数据成功, ${response.data}');
          pojo = VideoDetailPojo.fromJson(data.data);
        } else {
          pojo = null;
          logger.e('获取视频数据失败');
        }
      } else {
        pojo = null;
        logger.e('视频数据加载请求失败');
      }

      setState(() {
        if (pojo == null) {
          _errorMessage = 'pojo = null';
        }
        _videoDetail = pojo;
      });
      // setState(() {
      //   _videoDetail = mockData;
      //   // _isLoading = false;
      // });
      await _initializeVideoPlayer();
    } catch (e) {
      if (mounted) {
        setState(() {
          logger.e('在加载数据时失败: ${e.toString()}');
          _errorMessage = '数据加载失败: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // 初始化视频播放器
  Future<void> _initializeVideoPlayer() async {
    if (_videoDetail == null) {
      await _loadVideoData();
    }
    try {
      // await _loadVideoData();
      // _videoPlayerController =
      //     VideoPlayerController.asset('assets/videos/test.mp4');
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(_videoDetail!.videoSource))
            ..addListener(_handleVideoPlayerListener);
      await _videoPlayerController.initialize();

      final size = _videoPlayerController.value.size;
      logger.d('视频width: ${size.width}, height: ${size.height}');
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        // aspectRatio: 16 / 9,
        aspectRatio: size.height / size.width,
        autoInitialize: true,
        autoPlay: true,
        looping: false,
        // 隐藏默认控制栏
        showControls: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.white,
          backgroundColor: Color.fromRGBO(211, 211, 211, 0.3),
          bufferedColor: Color.fromRGBO(211, 211, 211, 0.1),
        ),
        placeholder: const Center(child: CircularProgressIndicator()),
        fullScreenByDefault: false,
        errorBuilder: (context, error) => const Center(child: Text('视频加载失败')),
      );
      _videoPlayerController.addListener(_handleVideoPlayerListener);

      // 启动隐藏视频控制按钮计时器
      _startHideControlsTimer();

      // 为页面滚动控制器添加监听器
      _scrollController.addListener(_handleScroll);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          logger.e('在初始化视频播放器时出现问题: ${e.toString()}');
          _errorMessage = '视频初始化失败: ${e.toString()}';
        });
      }
    }
  }

  // 构建加载动画
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
      ),
    );
  }

  // 构建错误动画
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('加载失败: $error', style: const TextStyle(color: Colors.black)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _retryLoading,
            child: Text('重试'),
          ),
        ],
      ),
    );
  }

  // 重试加载视频
  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _videoDetail = null;
    });
    _loadVideoData();
  }

  // 处理页面滚动
  void _handleScroll() {
    setState(() {
      double offset = _scrollController.offset;
      _appBarOpacity = offset > 0 ? (offset - kScrollThreshold) / 100.0 : 0.0;
      if (_appBarOpacity > 1.0) {
        _appBarOpacity = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_handleVideoPlayerListener);
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _hideControlsTimer?.cancel();

    // 退出时回复默认的屏幕方向
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  void _toggleFullScreen() async {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      // 进入全屏时将应用的显示方向设置为横屏
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      // 退出全屏时将应用的显示方向设置为竖屏
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {});
    }

    // _chewieController.toggleFullScreen();
    _restartHideControlsTimer();
  }

  // 切换视频播放和暂停
  void _togglePlayPause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
  }

  // 启动自动隐藏控制按钮计时器
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  // 重启自动隐藏控制按钮计时器
  void _restartHideControlsTimer() {
    _startHideControlsTimer();
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: _buildLoadingIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: _buildErrorWidget(_errorMessage!),
      );
    }

    if (_videoDetail == null) {
      return Scaffold(
        body: Center(
          child: Text('视频数据加载异常'),
        ),
      );
    }
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return _isFullScreen
        ? Scaffold(body: _buildFullScreenPlayer())
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    if (_scrollController.hasClients &&
                        _scrollController.offset > kScrollThreshold)
                      SliverAppBar(
                        leadingWidth: 100,
                        toolbarHeight: 40,
                        backgroundColor:
                            Color.fromRGBO(255, 64, 129, _appBarOpacity),
                        elevation: 0,
                        pinned: true,
                        leading: Row(
                          children: [
                            IconButton(
                              padding:
                                  const EdgeInsets.symmetric(vertical: -20),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                // TODO: 实现返回点击逻辑
                              },
                            ),
                            IconButton(
                              padding:
                                  const EdgeInsets.symmetric(vertical: -20),
                              icon: const Icon(Icons.home_outlined,
                                  color: Colors.white),
                              onPressed: () {
                                // TODO: 实现主页单点击逻辑
                              },
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            padding: const EdgeInsets.only(bottom: -20),
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              // TODO: 实现搜索点击逻辑
                            },
                          ),
                        ],
                      ),
                    SliverToBoxAdapter(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        // aspectRatio: _videoPlayerController.value.size.width / _videoPlayerController.value.size.height,
                        child: GestureDetector(
                          onTap: () {
                            if (_showControls) {
                              _showControls = !_showControls;
                              setState(() {
                                _hideControlsTimer?.cancel();
                              });
                            } else {
                              _restartHideControlsTimer();
                            }
                          },
                          child: Stack(
                            children: [
                              // 背景
                              Container(
                                color: Colors.black,
                              ),
                              // 视频组件
                              Chewie(controller: _chewieController),
                              // 进度条组件
                              if (_showControls)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: _buildTopControls(Colors.white),
                                ),
                              if (_showControls)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: _buildCustomControls(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        child: TabBar(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [Tab(text: '简介'), Tab(text: '评论')],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  // TODO: 加载视频详细数据
                  children: [
                    VideoInfoPage(videoDetail: _videoDetail!),
                    CommentPage()
                  ],
                  // children: [],
                ),
              ),
            ),
          );
  }

  Widget _buildTopControls(Color? iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: iconColor ?? Colors.white),
          onPressed: () {
            // TODO: 实现返回逻辑
            Navigator.of(context).pop();
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: iconColor ?? Colors.white),
          onPressed: () {
            // TODO: 实现更多操作逻辑
          },
        ),
      ],
    );
  }

  // 构建自定义的控制组件
  Widget _buildCustomControls() {
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _videoPlayerController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _togglePlayPause,
          ),
          Expanded(
            child: VideoProgressIndicator(
              _videoPlayerController,
              allowScrubbing: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_formatDuration(_videoPlayerController.value.position)} / ${_formatDuration(_videoPlayerController.value.duration)}',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: _toggleFullScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        if (_showControls) {
          _showControls = !_showControls;
          setState(() {
            _hideControlsTimer?.cancel();
          });
        } else {
          _restartHideControlsTimer();
        }
      },
      child: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          Chewie(controller: _chewieController),
          // 顶部左侧按钮
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue),
                onPressed: () {
                  _toggleFullScreen();
                },
              ),
            ),
          // 顶部右侧按钮
          if (_showControls)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.more_vert, color: Colors.blue),
                onPressed: () {
                  // TODO: 实现按钮点击逻辑
                },
              ),
            ),
          // 底部进度条等控制按钮
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCustomControls(),
            ),
        ],
      ),
    ));
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  const _StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
