class Friend {
  // 好友的 ID
  final String id;

  // 好友的用户名
  final String username;

  // 好友的用户头像
  final String avatarUrl;

  // 好友是否在群中
  final bool isInGroup;

  // 好友是否为最近的联系人
  final bool isRecent;

  // 好友是否被选中
  bool isSelected;

  Friend({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.isInGroup = false,
    this.isRecent = false,
    this.isSelected = false,
  });
}

// 模拟数据
class FriendRepository {
  static List<Friend> getRecentFriends() => [
        Friend(
          id: '1',
          username: '张三',
          avatarUrl: 'https://picsum.photos/200/200?random=2',
          isRecent: true,
          isInGroup: true,
        ),
        Friend(
          id: '2',
          username: '李四',
          avatarUrl: 'https://picsum.photos/200/200?random=5',
          isRecent: true,
        ),
      ];

  static List<Friend> getAllFriends() => [
        Friend(
          id: '3',
          username: '王五',
          avatarUrl: 'https://picsum.photos/200/200?random=1',
        ),
        Friend(
          id: '4',
          username: '赵六',
          avatarUrl: 'https://picsum.photos/200/200?random=3',
          isInGroup: true,
        ),
      ];
}
