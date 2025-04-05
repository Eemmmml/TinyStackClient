import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // 视频播放部分
              SliverToBoxAdapter(
                child: Container(
                  height: 250,
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
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
                  )
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // 简介页面
              Container(
                color: Colors.green,
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('视频简介', style: TextStyle(fontSize: 20)),
                    ),
                    Container(
                      // 占位高度
                      height: 800,
                      color: Colors.green[200],
                    ),
                  ],
                ),
              ),

              // 评论页面
              Container(
                color: Colors.blue[100],
                child: ListView(
                  children: [
                    // 添加评论列表
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('热门评论', style: TextStyle(fontSize: 20)),
                    ),
                    Container(
                      // 占位高度
                      height: 800,
                      color: Colors.blue[200],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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