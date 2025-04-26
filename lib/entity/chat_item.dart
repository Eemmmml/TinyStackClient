import 'package:intl/intl.dart';

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
  final DateTime timestamp;

  // 未读消息的数量
  final int unreadCount;

  // 是否置顶聊天
  final bool isPinned;

  // 是否隐藏聊天
  final bool isHidden;

  ChatItem({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    this.isPinned = false,
    this.isHidden = false,
  });

  ChatItem copyWith({
    String? id,
    String? name,
    bool? isGroup,
    String? avatarUrl,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    bool? isPinned,
    bool? isHidden,
  }) {
    return ChatItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == yesterday) {
      return "昨天 ${DateFormat('HH:mm').format(timestamp)}";
    } else if (now.difference(timestamp).inDays < 7) {
      // 显示周几，中文
      return DateFormat('E', 'zh_CN').format(timestamp);
    } else if (now.year != timestamp.year) {
      return DateFormat('yyyy/MM/dd').format(timestamp);
    } else {
      return DateFormat('MM/dd').format(timestamp);
    }
  }

  // 获取聊天信息数据
  // TODO: 从后台服务端获取聊天数据信息
  static List<ChatItem> get chatItems {
    final now = DateTime.now();

    // 辅助方法：创建指定时间的DateTime
    DateTime timeToday(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);

    // 辅助方法：获取最近指定周几的日期（1=周一，7=周日）
    DateTime recentWeekday(int weekday) {
      final today = now.weekday;
      final diff = (today - weekday + 7) % 7;
      return now.subtract(Duration(days: diff == 0 ? 7 : diff));
    }

    return [
      ChatItem(
        id: '1',
        name: '张三',
        isGroup: false,
        avatarUrl: 'https://picsum.photos/200/200?random=1',
        lastMessage: '你好，最近怎么样？',
        timestamp: timeToday(9, 30),
        // 当天09:30
        unreadCount: 2,
      ),
      ChatItem(
        id: '2',
        name: '技术交流群',
        isGroup: true,
        avatarUrl: 'https://picsum.photos/200/200?random=2',
        lastMessage: '李四：这个问题应该这样解决...',
        timestamp: now.subtract(const Duration(days: 1)),
        // 昨天
        unreadCount: 5,
      ),
      ChatItem(
        id: '3',
        name: '李四',
        isGroup: false,
        avatarUrl: 'https://picsum.photos/200/200?random=3',
        lastMessage: '好的，明天见！',
        timestamp: recentWeekday(3),
        // 最近周三
        unreadCount: 0,
      ),
      ChatItem(
        id: '4',
        name: '王五',
        isGroup: false,
        avatarUrl: 'https://picsum.photos/200/200?random=4',
        lastMessage: '周末一起去看电影吧？',
        timestamp: timeToday(12, 15),
        // 当天12:15
        unreadCount: 1,
      ),
      ChatItem(
        id: '5',
        name: '篮球爱好者群',
        isGroup: true,
        avatarUrl: 'https://picsum.photos/200/200?random=5',
        lastMessage: '周六下午三点球场见！',
        timestamp: now.subtract(const Duration(days: 2)),
        // 前天
        unreadCount: 3,
      ),
      ChatItem(
        id: '6',
        name: '赵六',
        isGroup: false,
        avatarUrl: 'https://picsum.photos/200/200?random=6',
        lastMessage: '我已经到公司了。',
        timestamp: timeToday(8, 45),
        // 当天08:45
        unreadCount: 0,
      ),
      ChatItem(
        id: '7',
        name: '读书分享群',
        isGroup: true,
        avatarUrl: 'https://picsum.photos/200/200?random=7',
        lastMessage: '这本书真的很不错，大家可以看看。',
        timestamp: now.subtract(const Duration(days: 7)),
        // 上周
        unreadCount: 8,
      ),
      ChatItem(
        id: '8',
        name: '孙七',
        isGroup: false,
        avatarUrl: 'https://picsum.photos/200/200?random=8',
        lastMessage: '晚上一起吃饭呀。',
        timestamp: timeToday(18, 0),
        // 当天18:00
        unreadCount: 2,
      ),
      ChatItem(
        id: '9',
        name: '摄影交流群',
        isGroup: true,
        avatarUrl: 'https://picsum.photos/200/200?random=9',
        lastMessage: '这张照片的构图太妙了！',
        timestamp: now.subtract(const Duration(days: 1)),
        // 昨天
        unreadCount: 6,
      ),
      ChatItem(
        id: '10',
        name: '周八',
        isGroup: false,
        avatarUrl: 'https://picsum.photos/200/200?random=10',
        lastMessage: '文件我已经发你邮箱了。',
        timestamp: timeToday(11, 20),
        // 当天11:20
        unreadCount: 0,
      ),
    ];
  }
}


