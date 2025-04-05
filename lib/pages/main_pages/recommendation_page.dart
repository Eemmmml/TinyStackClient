import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../entity/item_content.dart';
import '../card/content_card.dart';
import '../content_pages/video_detail_page.dart';

// 下拉方向
enum LoadDirection { up, down }

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  // 随机数，用来随机生成不同类型的页面
  final Random _random = Random();

  // 是否展示 Banner 用来区分两种页面
  bool _showBannerLayout = false;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 实际内容数据
  List<ContentItem> _contentItems = [];

  // 表示是否处于上拉加载状态
  bool _isTopLoading = false;

  // 表示是否处于下拉加载状态
  bool _isBottomLoading = false;

  // 上一次滚动的位置
  double _lastScrollPosition = 0;

  // 是否是下拉
  bool _isScrollingDown = false;

  // 表示是否还有更多的数据
  bool _hasMore = true;

  // 当前的页面号
  int _currentPage = 1;

  // 每页的元素数量
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _showBannerLayout = _random.nextBool();
    _scrollController.addListener(_scrollListener);
    _loadData(direction: LoadDirection.up);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // TODO: 增加实际从后台服务端通过网络获取数据
  Future<void> _loadData({required LoadDirection direction}) async {
    if ((direction == LoadDirection.down && _isBottomLoading) ||
        (direction == LoadDirection.up && _isTopLoading)) {
      return;
    }

    setState(() {
      if (direction == LoadDirection.down) {
        _isBottomLoading = true;
        _currentPage++;
      } else {
        _isTopLoading = true;
        _currentPage = 1;
      }
    });

    try {
      final newItems = await MockData.fetchData(_currentPage, _pageSize);

      setState(() {
        if (direction == LoadDirection.down) {
          _contentItems.addAll(newItems);
        } else {
          _contentItems = newItems;
        }
        _hasMore = newItems.length == _pageSize;
      });
    } finally {
      setState(() {
        if (direction == LoadDirection.down) {
          _isBottomLoading = false;
        } else {
          _isTopLoading = false;
        }
      });
    }
  }

  void _scrollListener() {
    final position = _scrollController.position;
    final currentPosition = position.pixels;

    // 判断滚动方向
    _isScrollingDown = currentPosition > _lastScrollPosition;
    _lastScrollPosition = currentPosition;

    // 上拉判断（仅当向下滚动时）
    if (_isScrollingDown &&
        currentPosition >= position.maxScrollExtent - 50 &&
        !_isBottomLoading &&
        _hasMore) {
      _loadData(direction: LoadDirection.down);
    }

    // 下拉判断
    if (!_isScrollingDown &&
        position.pixels <= position.minScrollExtent + 100 &&
        !_isTopLoading) {
      _loadData(direction: LoadDirection.up);
    }
  }

  Future<void> _handleRefresh() async {
    // TODO: 实现真实的数据刷新逻辑
    setState(() {
      _currentPage = 1;
      _contentItems.clear();
      _hasMore = true;
      _showBannerLayout = _random.nextBool();
    });

    await _loadData(direction: LoadDirection.up);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.green,
        displacement: 30,
        edgeOffset: 30,
        onRefresh: _handleRefresh,
        child: _showBannerLayout ? _buildBannerLayout() : _buildNormalLayout(),
      ),
    );
  }

  // 构建含 Banner 的页面
  Widget _buildBannerLayout() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildBanner()),
        _buildContentSliverGrid(),
        SliverToBoxAdapter(child: _buildBottomLoader()),
      ],
    );
  }

  Widget _buildContentSliverGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _contentItems[index];
          return InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoDetailPage()));
            },
            borderRadius: BorderRadius.circular(8),
            child: ContentCard(
              title: item.title,
              author: item.author,
              imageUrl: item.imageUrl,
            ),
          );
        },
        childCount: _contentItems.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
    );
  }

  // 构建正常的页面
  Widget _buildNormalLayout() {
    return _buildContentGrid(itemCount: 10);
  }

  // 构建 Banner 视图
  Widget _buildBanner() {
    return RandomBanner();
  }

  // 构建网格视图
  Widget _buildContentGrid({required int itemCount}) {
    return Column(
      children: [
        // _buildTopLoader(),
        Expanded(
            child: GridView.builder(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: _contentItems.length,
          itemBuilder: (context, index) {
            final item = _contentItems[index];
            return InkWell(
              onTap: () {
                // TODO: 实现页面跳转逻辑
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoDetailPage()));
              },
              borderRadius: BorderRadius.circular(8),
              child: ContentCard(
                title: item.title,
                author: item.author,
                imageUrl: item.imageUrl,
              ),
            );
          },
        )),
        _buildBottomLoader(),
      ],
    );
  }

  // // 构建下拉刷新动画
  // Widget _buildTopLoader() {
  //   return AnimatedContainer(
  //     duration: Duration(milliseconds: 300),
  //     height: _isTopLoading ? 60 : 0,
  //     child: Center(
  //       child: _isTopLoading ? CircularProgressIndicator() : SizedBox.shrink(),
  //     ),
  //   );
  // }

  // 构建上拉加载动画
  Widget _buildBottomLoader() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isBottomLoading ? 45 : 0,
      child: Center(
        child: _isBottomLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                backgroundColor: Colors.grey,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round,
              )
            : _hasMore
                ? SizedBox.shrink()
                : Text('没有更多内容了'),
      ),
    );
  }
}

class RandomBanner extends StatefulWidget {
  const RandomBanner({super.key});

  @override
  State<RandomBanner> createState() => _RandomBannerState();
}

// 构建 Banner 页面
class _RandomBannerState extends State<RandomBanner> {
  final PageController _pageController = PageController();
  final int _bannerCount = 5;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _currentPage = (_currentPage + 1) % _bannerCount;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _timer?.cancel();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: List.generate(
                _bannerCount,
                (index) =>
                    _buildBannerItem('assets/user_info/user_avatar1.jpg')),
          ),
        ),
        _buildIndicator(),
      ],
    );
  }

  // 创建指示器
  Widget _buildIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_bannerCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? Colors.white : Colors.grey,
            ),
          );
        }),
      ),
    );
  }

  // // 构建 Banner 内部元素
  // Widget _buildBannerItem(String imageUrl) {
  //   return Container(
  //     margin: EdgeInsets.all(8),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       image: DecorationImage(
  //         // TODO: 将图片获取改为从网络进行获取
  //         // image: NetworkImage(imageUrl),
  //         image: AssetImage(imageUrl),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

  // 构建 Banner 内部元素
  Widget _buildBannerItem(String imageUrl) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VideoDetailPage()));
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            // TODO: 将图片获取改为从网络进行获取
            // image: NetworkImage(imageUrl),
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
