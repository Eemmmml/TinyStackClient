class ChatItem {
  // 聊天的 ID
  final String id;

  // 聊天名称
  final String name;

  // 区分群聊和好友
  final bool isGroup;

  // 群聊或好友的头像
  final String avatarUrl;

  // 最近一次的消息
  final String lastMessage;

  // 最近一次通信的时间
  final String time;

  // 未读消息的数量
  final int unreadCount;

  ChatItem({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });

  // 获取聊天信息数据
  // TODO: 从后台服务端获取聊天数据信息
  static List<ChatItem> get chatItems {
    return [
      ChatItem(
        id: '1',
        name: '张三',
        isGroup: false,
        avatarUrl: 'assets/user_info/user_avatar1.jpg',
        lastMessage: '你好，最近怎么样？',
        time: '09:30',
        unreadCount: 2,
      ),
      ChatItem(
        id: '2',
        name: '技术交流群',
        isGroup: true,
        avatarUrl: 'assets/user_info/user_avatar2.jpg',
        lastMessage: '李四：这个问题应该这样解决...',
        time: '昨天',
        unreadCount: 5,
      ),
      ChatItem(
        id: '3',
        name: '李四',
        isGroup: false,
        avatarUrl: 'assets/user_info/user_avatar3.jpg',
        lastMessage: '好的，明天见！',
        time: '周三',
        unreadCount: 0,
      ),
    ];
  }
}
