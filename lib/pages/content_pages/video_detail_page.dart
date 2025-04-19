import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'comment_page.dart';
import 'video_info_page.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  static const double kScrollThreshold = 50; // 滑动阈值，可根据需要调整

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
    _videoPlayerController =
        VideoPlayerController.asset('assets/videos/test.mp4');
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
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
  }

  void _handleVideoPlayerListener() {
    if (_videoPlayerController.value.isInitialized && mounted) {
      setState(() {});
    }
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
                        aspectRatio: _chewieController.aspectRatio ?? 16 / 9,
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
                body: const TabBarView(
                  children: [VideoInfoPage(), CommentPage()],
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
