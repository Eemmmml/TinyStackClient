import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'comment_page.dart';
import 'video_info_page.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  // 视频播放控制器
  late VideoPlayerController _videoController;
  bool _showControls = true;
  bool _isPlaying = true;
  bool _isFullScreen = false;


  @override
  void initState() {
    super.initState();
    // TODO: 从后台服务端获取视频资源
    _videoController = VideoPlayerController.asset('assets/videos/test.mp4')..initialize()
        .then((_) {
       setState(() {

       });
       _videoController.play();
    })..addListener(_videoListener);
  }


  // 视频播放监听器
  void _videoListener() {
    if (_videoController.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _videoController.value.isPlaying;
      });
    }
  }


  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return _isFullScreen ? _buildFullScreenPlayer() : DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // 视频播放部分
              SliverToBoxAdapter(
                child: _buildVideoPlayer(),
              ),
              // 吸顶 Tab 栏
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                    child: TabBar(
                      // 指示器颜色
                      indicatorColor: Colors.blue,
                      // 选中标签颜色
                      labelColor: Colors.black,
                      // 未选中标签的颜色
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: '简介'),
                        Tab(text: '评论'),
                      ],
                    )),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // 简介页面
              VideoInfoPage(),
              // Container(
              //   color: Colors.green,
              //   child: ListView(
              //     children: [
              //       const Padding(
              //         padding: EdgeInsets.all(16),
              //         child: Text('视频简介', style: TextStyle(fontSize: 20)),
              //       ),
              //       Container(
              //         // 占位高度
              //         height: 800,
              //         color: Colors.green[200],
              //       ),
              //     ],
              //   ),
              // ),

              // 评论页面
              CommentPage(),
            ],
          ),
        ),
      ),
    );
  }


  // 构建视频播放器
  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: GestureDetector(
        onTap: () => setState(() {
          _showControls = !_showControls;
        }),
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController),
            if (_showControls) _buildVideoControls(),
            if (!_videoController.value.isInitialized)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }


  // 构建视频控制
  Widget _buildVideoControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent]
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow
                  ),
                  onPressed: _togglePlayPause,
                ),
              ],
            ),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }


  // 构建进度条
  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      _videoController,
      allowScrubbing: true,
      padding: const EdgeInsets.all(8),
      colors: const VideoProgressColors(
        playedColor: Colors.red,
        bufferedColor: Colors.grey,
        backgroundColor: Colors.white24,
      ),
    );
  }


  // 转换播放暂停和开始状态
  void _togglePlayPause() {
    setState(() {
      _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
    });
  }


  // 转换全屏和缩小化视图
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
    // 锁定竖屏（需要导入services库）
      // SystemChrome.setPreferredOrientations([
      //   DeviceOrientation.landscapeLeft,
      //   DeviceOrientation.landscapeRight,
      // ]);
    } else {
      // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }



// 构建全屏播放器
  Widget _buildFullScreenPlayer() {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            ),
            if (_showControls) _buildFullScreenPlayer()
          ],
        ),
      ),
    );
  }


  // 构建全屏控制
  Widget _buildFullScreenControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.fullscreen_exit),
                onPressed: _toggleFullScreen,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
              ],
            ),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }
}




// 自定义吸顶 Tab 栏实现
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      // Tab 背景颜色
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
    return false;
  }
}
