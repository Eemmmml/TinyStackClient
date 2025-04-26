import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinystack/entity/group_item.dart';

import '../../entity/chat_item.dart';
import '../../entity/chat_message_item.dart';
import 'group_info_page.dart';
import 'image_detail_screen.dart';

class ChatPage extends StatefulWidget {
  final ChatItem currentChat;
  static const double _avatarRadius = 18; // 头像尺寸
  static const double _bubbleSpacing = 8; // 气泡间距

  const ChatPage({super.key, required this.currentChat});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 文本编辑控制器
  final TextEditingController _messageController = TextEditingController();

  // 消息列表
  final List<ChatMessageItem> _messages = [];

  // 焦点
  final FocusNode _focusNode = FocusNode();

  // 社群的设置项
  final List<SettingItem> settings = SettingItem.settings;

  @override
  void initState() {
    super.initState();
    _messages.addAll(mockMessages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessageItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: text,
        timestamp: DateTime.now(),
        senderId: currentUserId,
        type: MessageType.text);

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageWithGroups = _getMessageWithTimeGroups();

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: widget.currentChat.isGroup
                  ? () {
                      // TODO: 实现按钮点击逻辑
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GroupInfoPage()));
                    }
                  : null,
            ),
          ],
          title: Row(
            children: [
              // 群组图标（如果是群聊）
              if (widget.currentChat.isGroup) const Icon(Icons.group, size: 20),
              const SizedBox(width: 8),
              Text(widget.currentChat.name),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[200],
          child: Column(
            children: [
              // 聊天历史区域
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _focusNode.unfocus();
                  },
                  child: Container(
                    color: Colors.grey[200],
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      reverse: true,
                      itemCount: messageWithGroups.length,
                      itemBuilder: (context, index) {
                        final item = messageWithGroups[index];
                        // 实现消息气泡组件
                        if (item is TimeGroup) {
                          return _buildTimeStamp(item.formattedTime);
                        }
                        return _buildMessageBubble(item as ChatMessageItem);
                      },
                    ),
                  ),
                ),
              ),
              // 文本输入区域
              _buildInputArea(),
            ],
          ),
        ));
  }

  // 构建输入区域
  Widget _buildInputArea() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 输入框
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  // 禁止自动获取焦点
                  autofocus: false,
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 发送按钮
              Transform.translate(
                offset: const Offset(0, -4),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  iconSize: 30,
                ),
              ),
            ],
          ),
        ),
        // 底部功能按钮行
        _buildFeatureButtons(),
      ],
    );
  }

  // 构建底部功能按钮行
  Widget _buildFeatureButtons() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                // TODO: 实现语音输入逻辑
              },
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                // TODO: 实现图片发送逻辑
                _pickImage();
              },
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                // TODO: 实现视频发送逻辑
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () {
                // TODO: 实现更多功能逻辑
              },
            ),
          ],
        ),
      ),
    );
  }

  // 生成带时间分组的消息列表
  List<dynamic> _getMessageWithTimeGroups() {
    if (_messages.isEmpty) return [];

    List<dynamic> results = [];
    DateTime? previousTime;

    for (var msg in _messages.reversed) {
      results.add(msg);
      if (previousTime == null ||
          msg.timestamp.difference(previousTime).inMinutes.abs() > 5) {
        results.add(_createTimeGroup(msg.timestamp));
        previousTime = msg.timestamp;
      }
    }
    return results;
  }

  // 创建时间组
  TimeGroup _createTimeGroup(DateTime time) {
    final now = DateTime.now();
    final format = time.year != now.year
        ? 'yyyy/MM/dd HH:mm'
        : (time.month != now.month || time.day != now.day)
            ? 'MM/dd HH:mm'
            : 'HH:mm';

    return TimeGroup(
        time: time, formattedTime: DateFormat(format).format(time));
  }

  // 生成时间戳
  Widget _buildTimeStamp(String time) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // 生成消息气泡
  Widget _buildMessageBubble(ChatMessageItem message) {
    final isMe = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ChatPage._bubbleSpacing),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildMessageAvatar(message, isMe),
          if (!isMe) const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 群聊时显示用户名
                if (widget.currentChat.isGroup)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 6,
                      bottom: 12,
                    ),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                _buildBubbleContent(message, isMe),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
          if (isMe) _buildMessageAvatar(message, isMe),
        ],
      ),
    );
  }

  // 构建消息发送方头像
  Widget _buildMessageAvatar(ChatMessageItem message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(
        right: isMe ? 2 : 6,
        left: isMe ? 6 : 2,
      ),
      child: CircleAvatar(
        radius: ChatPage._avatarRadius,
        backgroundImage: NetworkImage(message.avatarUrl),
      ),
    );
  }

  // 构建气泡内容
  Widget _buildBubbleContent(ChatMessageItem message, bool isMe) {
    return GestureDetector(
      // 拦截事件但不处理
      onTap: () {},
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.white,
          borderRadius: _getBubbleRadius(isMe),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 消息内容
            _buildMessageContent(message),
          ],
        ),
      ),
    );
  }

  // 获取消息气泡的圆角半径
  BorderRadius _getBubbleRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );
  }

  // 获取消息圆角半径
  BorderRadius _getContentRadius(ChatMessageItem message) {
    return BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );
  }

  // 构建消息气泡的消息内容
  Widget _buildMessageContent(ChatMessageItem message) {
    switch (message.type) {
      case MessageType.image:
        if (message.status == MessageStatus.uploading) {
          // 上传中的状态
          return _buildUploadingState(message);
        }
        return ClipRRect(
          borderRadius: _getContentRadius(message),
          child: InkWell(
            onTap: () => _openImageDetail(context, message.content),
            child: Hero(
              tag: 'image_hero_${message.id}',
              flightShuttleBuilder: (flightContext, animation, flightDirection,
                  flightHeroContext, toHeroContext) {
                final Image heroImage =
                    Image.network(message.content, fit: BoxFit.cover);

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final curvedValue =
                        Curves.easeInOutCubic.transform(animation.value);

                    return Material(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // 背景蒙版动画
                          Container(
                            color: Color.fromRGBO(0, 0, 0, curvedValue * 0.9),
                          ),
                          // 图片缩放动画
                          Transform.scale(
                            scale: Tween<double>(begin: 1.0, end: 1.05)
                                .transform(curvedValue),
                            child: Opacity(
                              opacity: Tween<double>(begin: 1.0, end: 0.8)
                                  .transform(curvedValue),
                              child: heroImage,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: heroImage,
                );
              },
              child: Image.network(
                message.content,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  // 图片加载渐显动画
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  // 统一加载进度组件
                  return _buildLoadingProgress(loadingProgress);
                },
                errorBuilder: (context, error, stackTrace) {
                  // 错误状态
                  return _buildErrorState(message);
                },
              ),
            ),
          ),
        );
      case MessageType.video:
        return ClipRRect(
          borderRadius: _getContentRadius(message),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                'https://picsum.photos/120/90?random=4',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              const Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Colors.white70,
              )
            ],
          ),
        );
      case MessageType.emoji:
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Image.network(message.content, width: 80, height: 80),
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        );
    }
  }

  // 加载进度组件
  Widget _buildLoadingProgress(ImageChunkEvent progress) {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
          if (progress.expectedTotalBytes != null)
            Positioned(
              bottom: 10,
              child: Text(
                '${(progress.cumulativeBytesLoaded / 1024).toStringAsFixed(1)}KB/${(progress.expectedTotalBytes! / 1024).toStringAsFixed(1)}KB',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 上传中的状态组件
  Widget _buildUploadingState(ChatMessageItem message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: _getContentRadius(message),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: message.progress,
                strokeWidth: 2,
              ),
              if (message.progress != null)
                Text(
                  '${(message.progress! * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '正在上传...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 错误状态组件
  Widget _buildErrorState(ChatMessageItem message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: _getContentRadius(message),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 40),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _retryUpload(message),
            child: const Text('重新选择并上传'),
          ),
        ],
      ),
    );
  }

  // 模拟图片上传过程
  void _mockUploadImage(File file, ChatMessageItem message) async {
    try {
      // 模拟上传进度
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          message.progress = i / 100;
        });
      }

      setState(() {
        // TODO: 替换为真实云端 URL
        message.content =
            'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}';
        message.status = MessageStatus.sent;
      });
    } catch (e) {
      setState(() {
        message.status = MessageStatus.failed;
        _showErrorSnackBar('图片上传失败：${e.toString()}');
      });
    }
  }

  // 重新上传逻辑
  void _retryUpload(ChatMessageItem originalMessage) async {
    // 打开系统相册选择新图片
    final List<XFile>? newImages = await ImagePicker().pickMultiImage(
      imageQuality: 70,
    );

    if (newImages == null || newImages.isEmpty) {
      debugPrint('至少选择一个图片');
      return;
    }

    // 移除原始失败消息
    setState(() {
      _messages.remove(originalMessage);
    });

    // 处理选择新的图片
    for (final image in newImages) {
      final newMessage = ChatMessageItem(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        // 进行占位
        content: '',
        timestamp: DateTime.now(),
        senderId: currentUserId,
        type: MessageType.image,
        status: MessageStatus.uploading,
        progress: 0,
      );

      setState(() {
        _messages.add(newMessage);
      });

      // 开始上传新图片
      try {
        // TODO: 替换为真实的上传逻辑
        final String imageUrl =
            await _uploadImageToCloud(File(image.path), newMessage);

        setState(() {
          newMessage.content = imageUrl;
          newMessage.status = MessageStatus.sent;
        });
      } catch (e) {
        setState(() {
          newMessage.status = MessageStatus.failed;
          _showErrorSnackBar('图片上传失败： ${e.toString()}');
        });
      }
    }
  }

  // 图片上传方法
  Future<String> _uploadImageToCloud(
      File imageFile, ChatMessageItem message) async {
    // TODO: 实现真实的上传逻辑

    // 模拟上传进度
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        message.progress = i / 100;
      });
    }
    return 'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}';
  }

  // 打开图片查看页面
  void _openImageDetail(BuildContext context, String imageUrl) {
    // 新增焦点释放
    _focusNode.unfocus();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageDetailScreen(imageUrl: imageUrl);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOutCubic;

          var fadeTween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var scaleTween =
              Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve));

          return FadeTransition(
            opacity: fadeTween.animate(animation),
            child: ScaleTransition(
              scale: scaleTween.animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // 从设备中选择图片并发送图片消息的方法
  void _pickImage() async {
    // 请求访问存储权限
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      debugPrint('返回3');
      _showToast('图片访问权限被拒绝');
      return;
    }
    final List<XFile> images =
        await ImagePicker().pickMultiImage(imageQuality: 70);

    if (images == null || images.isEmpty) {
      debugPrint('请选择至少一张图片');
      return;
    }

    for (final image in images) {
      final tempImage = ChatMessageItem(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        // 先占位
        content: '',
        timestamp: DateTime.now(),
        senderId: currentUserId,
        type: MessageType.image,
        status: MessageStatus.uploading,
        progress: 0,
      );

      _mockUploadImage(File(image.path), tempImage);

      setState(() {
        _messages.add(tempImage);
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 显示错误提示
  void _showErrorSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            // TODO: 实现点击逻辑
          },
        ),
      ),
    );
  }
}
