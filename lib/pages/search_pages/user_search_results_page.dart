// 排序类型枚举
import 'package:flutter/material.dart';

import '../../entity/user_item.dart';

enum SortType { fans, posts }

class UserSearchResultsPage extends StatefulWidget {
  const UserSearchResultsPage({super.key});

  @override
  State<UserSearchResultsPage> createState() => _UserSearchResultsPageState();
}

class _UserSearchResultsPageState extends State<UserSearchResultsPage> {
  List<User> _users = [];
  SortType _currentSortType = SortType.fans;
  int _resultCount = 0;

  @override
  void initState() {
    super.initState();
    // 模拟数据
    _users = [
      User(
        id: '1',
        username: '用户1',
        avatarUrl: 'https://picsum.photos/200/200?random=1',
        followersCount: 12345,
        postsCount: 256,
        bio: '这是一个用户简介的例子，可能会比较长需要截断处理',
      ),
      User(
        id: '2',
        username: '用户2',
        avatarUrl: 'https://picsum.photos/200/200?random=1',
        followersCount: 856,
        postsCount: 1234,
        bio: '另一个用户简介的例子',
      ),
    ];

    _resultCount = _users.length;
    _sortUsers();
  }

  // 用户排序
  void _sortUsers() {
    switch (_currentSortType) {
      case SortType.fans:
        _users.sort((a, b) => b.followersCount.compareTo(a.followersCount));
        break;
      case SortType.posts:
        _users.sort((a, b) => b.postsCount.compareTo(a.postsCount));
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
            title: Text('按粉丝数排序'),
            value: SortType.fans,
            groupValue: _currentSortType,
            onChanged: (value) {
              setState(() {
                _currentSortType = value!;
                _sortUsers();
              });
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: Text('按投稿数排序'),
            value: SortType.posts,
            groupValue: _currentSortType,
            onChanged: (value) {
              setState(() {
                _currentSortType = value!;
                _sortUsers();
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
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        '粉丝 ${user.followersCount.formatCount()} · 投稿 ${user.postsCount.formatCount()}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      minimumSize: Size(80, 36),
                      // 更合理的尺寸
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: user.isFollowing
                          ? Colors.grey[300]
                          : Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _toggleFollow(user),
                    child: user.isFollowing
                        ? Text('已关注', style: TextStyle(color: Colors.grey[700]))
                        : Row(
                            mainAxisSize: MainAxisSize.min, // 防止Row过度扩展
                            children: [
                              Icon(Icons.add, size: 18, color: Colors.white),
                              SizedBox(width: 4),
                              Text('关注', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
