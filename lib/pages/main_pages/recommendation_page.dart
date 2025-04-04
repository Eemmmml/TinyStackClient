import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../card/content_card.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final Random _random = Random();

  // 是否展示 Banner 用来区分两种页面
  bool _showBannerLayout = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _showBannerLayout = _random.nextBool();
  }

  Future<void> _handleRefresh() async {
    // TODO: 实现真实的数据刷新逻辑
    setState(() {
      _showBannerLayout = _random.nextBool();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _showBannerLayout ? _buildBannerLayout() : _buildNormalLayout(),
      ),
    );
  }

  // 构建含 Banner 的页面
  Widget _buildBannerLayout() {
    return Column(
      children: [
        _buildBanner(),
        Expanded(child: _buildContentGrid(itemCount: 8)),
      ],
    );
  }

  // 构建正常的页面
  Widget _buildNormalLayout() {
    return _buildContentGrid(itemCount: 10);
  }

  // 构建 Banner 视图
  Widget _buildBanner() {
    // return SizedBox(
    //   height: 180,
    //   child: PageView(
    //     // TODO: 实现自动轮播播放
    //     children: [
    //       _buildBannerItem('assets/user_info/user_avatar1.jpg'),
    //       _buildBannerItem('assets/user_info/user_avatar2.jpg'),
    //       _buildBannerItem('assets/user_info/user_avatar3.jpg'),
    //     ],
    //   ),
    // );
    return RandomBanner();
  }

  // 构建 Banner 内部元素
  Widget _buildBannerItem(String imageUrl) {
    return Container(
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
    );
  }

  // 构建网格视图
  Widget _buildContentGrid({required int itemCount}) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => ContentCard(
        // TODO: 修改为实际的数据
        title: '标题 ${index + 1}',
        author: '作者 ${index + 1}',
        imageUrl: 'assets/user_info/user_avatar.jpg',
      ),
    );
  }
}

class RandomBanner extends StatefulWidget {
  const RandomBanner({super.key});

  @override
  State<RandomBanner> createState() => _RandomBannerState();
}

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
          height: 250,
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

  // 构建 Banner 内部元素
  Widget _buildBannerItem(String imageUrl) {
    return Container(
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
    );
  }
}
