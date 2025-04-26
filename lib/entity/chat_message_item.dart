// 聊天信息数据模型
class ChatMessageItem {
  final String id;
  final String content;
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String avatarUrl;
  // 消息状态
  MessageStatus status;
  // 消息上传进度 0-1
  double? progress;


  ChatMessageItem({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.senderId,
    this.senderName = '',
    this.type = MessageType.text,
    this.avatarUrl = 'https://picsum.photos/200/200?random=4',
    this.status = MessageStatus.sent,
    this.progress,
  });
}

// 消息状态枚举类
enum MessageStatus {
  uploading, // 消息上传中
  sent, // 消息发送成功
  failed, // 消息发送失败
}

// 消息类型
enum MessageType {
  // 文本信息
  text,
  // 图片信息
  image,
  // 视频信息
  video,
  // 表情信息
  emoji,
}

// 时间分组数据模型
class TimeGroup {
  final DateTime time;
  final String formattedTime;

  TimeGroup({
    required this.time,
    required this.formattedTime,
  });
}

// 模拟当前用户ID
const String currentUserId = 'user_123';

// 生成测试用消息列表
List<ChatMessageItem> generateMockMessages() {
  final now = DateTime.now();
  return [
    // 最新消息（当前用户发送）
    ChatMessageItem(
      id: '10',
      content: '这个功能看起来不错！',
      timestamp: now,
      senderId: currentUserId,
      senderName: 'Jane',
      type: MessageType.text,
    ),

    // 4分钟前的消息（不同用户，测试不超过5分钟不分组）
    ChatMessageItem(
      id: '9',
      content: 'https://picsum.photos/120/90?random=4',
      timestamp: now.subtract(const Duration(minutes: 4)),
      senderId: 'user_456',
      senderName: 'Mike',
      type: MessageType.image,
    ),

    // 10分钟前的消息（触发时间分组）
    ChatMessageItem(
      id: '8',
      content: '🎉',
      timestamp: now.subtract(const Duration(minutes: 10)),
      senderId: 'user_789',
      senderName: 'Json',
      type: MessageType.emoji,
    ),

    // 昨天的消息（测试日期格式）
    ChatMessageItem(
      id: '7',
      content: 'https://example.com/demo.mp4',
      timestamp: DateTime(now.year, now.month, now.day - 1, 15, 30),
      senderId: currentUserId,
      senderName: 'Kevin',
      type: MessageType.video,
    ),

    // 跨月消息（测试MM-dd格式）
    ChatMessageItem(
      id: '6',
      content: '项目文档已更新',
      timestamp: DateTime(now.year, now.month - 1, 28, 9, 15),
      senderId: 'user_456',
      senderName: 'Hel',
      type: MessageType.text,
    ),

    // 跨年消息（测试完整日期格式）
    ChatMessageItem(
      id: '5',
      content: '新年快乐！🎆',
      timestamp: DateTime(now.year - 1, 12, 31, 23, 59),
      senderId: 'user_789',
      senderName: 'No',
      type: MessageType.text,
    ),

    // 群组消息（测试长文本换行）
    ChatMessageItem(
      id: '4',
      content: '这是一个非常长的文本消息，用于测试自动换行和气泡扩展效果。'
          '当文字超过一定长度时，应该自动换行显示，同时保持气泡的圆角效果。',
      timestamp: DateTime(now.year - 1, 6, 15, 10, 0),
      senderId: 'user_456',
      senderName: 'No',
      type: MessageType.text,
    ),

    // 混合内容测试
    ChatMessageItem(
      id: '3',
      content: 'https://picsum.photos/120/90?random=2',
      timestamp: DateTime(now.year - 1, 3, 20, 14, 30),
      senderId: currentUserId,
      senderName: 'No',
      type: MessageType.image,
    ),

    ChatMessageItem(
      id: '2',
      content: '会议记录视频',
      timestamp: DateTime(now.year - 1, 3, 20, 14, 25),
      senderId: 'current_user',
      senderName: 'No',
      type: MessageType.video,
    ),

    // 最早的消息（测试列表底部）
    ChatMessageItem(
      id: '1',
      content: '欢迎加入群聊！',
      timestamp: DateTime(now.year - 1, 1, 1, 8, 0),
      senderId: 'system',
      senderName: 'No',
      type: MessageType.text,
    ),
  ];
}

// 初始化测试数据
final List<ChatMessageItem> mockMessages = generateMockMessages();
