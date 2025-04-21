import 'package:flutter/material.dart';
import 'package:tinystack/entity/user_profile_attachment.dart';

import 'profile_page_for_others_attachment_page.dart';
import 'user_main_page.dart';
import 'user_post_page.dart';

class ProfilePageForOthers extends StatefulWidget {
  const ProfilePageForOthers({super.key});

  @override
  State<ProfilePageForOthers> createState() => _ProfilePageForOthersState();
}

class _ProfilePageForOthersState extends State<ProfilePageForOthers> {
  final ScrollController _scrollController = ScrollController();

  // 是否展开用户简介
  bool _isDescriptionExpanded = false;

  // 是否关注了当前用户
  bool _isFollowed = false;

  // 新增滚动监听变量
  double _scrollOffset = 0;

  // 根据实际内容调整阀值
  bool get _showFullAppBar => _scrollOffset > 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 新增的动态 AppBar
              SliverAppBar(
                leadingWidth: 60,
                expandedHeight: 160,
                pinned: true,
                floating: false,
                snap: false,
                backgroundColor:
                    _showFullAppBar ? Colors.white : Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/user_background.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 27,
                        bottom: -65,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/user_info/user_avatar2.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: AnimatedOpacity(
                  opacity: _showFullAppBar ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: _buildTitleWidget(),
                ),
                leading: !_showFullAppBar
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 20,
                        // 实际生效的容器尺寸（直径）
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 16,
                          // 实际图标尺寸
                          padding: EdgeInsets.all(8),
                          // 关键：通过 padding 控制热区
                          constraints: BoxConstraints(
                            minWidth: 0, // 必须重置最小约束
                            minHeight: 0,
                          ),
                          splashRadius: 20,
                          // 水波纹与容器尺寸匹配
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.blue),
                        onPressed: () {},
                      ),
                actions: !_showFullAppBar
                    ? [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 40,
                          // 实际生效的容器尺寸（直径）
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 16,
                            // 实际图标尺寸
                            padding: EdgeInsets.all(8),
                            // 关键：通过 padding 控制热区
                            constraints: BoxConstraints(
                              minWidth: 0, // 必须重置最小约束
                              minHeight: 0,
                            ),
                            splashRadius: 20,
                            // 水波纹与容器尺寸匹配
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ]
                    : [
                        Opacity(
                          opacity: 0.5,
                          child: IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // TODO: 实现按钮点击逻辑
                            },
                          ),
                        ),
                      ],
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 15),
                  // 为头像留出空间
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 27,
                        top: -50,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/user_info/user_avatar2.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // 用户信息区域
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 140), // 头像占位宽度
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem('1.2万', '粉丝'),
                                      _buildStatItem('345', '关注'),
                                      _buildStatItem('5.6万', '获赞'),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _toggleIsFollowed,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: _isFollowed
                                              ? Colors.grey[400]
                                              : Colors.pinkAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          )),
                                      // child: Text(_isFollowed ? '取关' : '+关注'),
                                      child: _isFollowed
                                          ? Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .format_list_bulleted,
                                                      color: Colors.grey[600]),
                                                  const SizedBox(width: 3),
                                                  Text('已关注',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w900)),
                                                ],
                                              ),
                                            )
                                          : Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add,
                                                      color: Colors.white),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '关注',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 用户名和简介
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '用户名用户名用户名用户名用户名',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        // 动态的用户简介
                        _buildDynamicDescription(),
                      ],
                    ),
                  ),
                ]),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: TabBar(
                    tabs: [
                      Tab(text: '主页'),
                      Tab(text: '动态'),
                      Tab(text: '投稿'),
                    ],
                    indicatorWeight: 3,
                    indicatorColor: Colors.pinkAccent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              UserMainPage(),
              DynamicList(dynamics: Dynamic.dynamics()),
              UserPostsPage(),
            ],
          ),
        ),
      ),
    );
  }

  // 新增构建标题组件的方法
  Widget _buildTitleWidget() {
    return _isFollowed
        ? Center(
            child: Text(
              '用户名用户名用户名',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : InkWell(
            onTap: () {
              setState(() {
                if (!_isFollowed) {
                  _isFollowed = true;
                }
              });
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      // TODO: 通过网络获取实际用户头像
                      backgroundImage:
                          AssetImage('assets/user_info/user_avatar2.jpg'),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '+关注',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  // 创建用户数据栏
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicDescription() {
    return GestureDetector(
      onTap: _toggleDescription,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          // 文本内容
          Padding(
            padding: EdgeInsets.only(right: 40), // 为按钮预留空间
            child: Text(
              '这里是用户简介，可以很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长',
              maxLines: _isDescriptionExpanded ? null : 1,
              overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          // 详情按钮（始终在首行右侧）
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              color: Colors.transparent, // 添加透明背景防止文字穿透
              child: Text(
                _isDescriptionExpanded ? '收起' : '详情',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 切换标签的展开状态
  void _toggleDescription() {
    setState(() {
      _isDescriptionExpanded = !_isDescriptionExpanded;
    });
  }

  // 切换是否关注当前用户
  void _toggleIsFollowed() {
    setState(() {
      _isFollowed = !_isFollowed;
    });
  }

  Widget _buildContentPage(Color color) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(8),
      itemCount: 50,
      itemBuilder: (context, index) {
        return Container(
          height: 80,
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('内容项 ${index + 1}')),
        );
      },
    );
  }
}

// 固定Tab栏的委托类
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  _StickyTabBarDelegate({required this.child});

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
    return false;
  }
}
