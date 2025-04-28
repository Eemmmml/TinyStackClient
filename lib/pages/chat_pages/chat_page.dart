import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:tinystack/entity/group_item.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  // 用来实现文本选择框中选择状态
  EditableTextState? _editableTextState;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 录音器
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  // 语音播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 录音状态
  bool _isRecording = false;

  // 音频播放状态
  bool _isAudioPlaying = false;

  // 当前播放音频的 ID
  String? _currentAudioPlayingId;

  // TODO: 将永久密钥替换为获取的临时密钥
  // 腾讯云 SecretId
  final String _secretId = 'AKIDIVZQ2PXR5UhmhRyINGvOdcPyINDoAIAQ';

  // 腾讯云 SecretKey
  final String _secretKey = '70f5HI6lOo0xFOJzRjrnUzHNK7jDj9OQ';

  // 腾讯云存储桶名称
  final String _voiceBucket = 'tinystack-voice-store-1356865752';

  @override
  void initState() {
    super.initState();
    _messages.addAll(mockMessages);
    // 初始化录音控制器
    _initRecorder();
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isAudioPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    // 销毁录音控制器
    _recorder.closeRecorder();
    // 销毁音频播放器
    _audioPlayer.dispose();
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
                child: NotificationListener<ScrollStartNotification>(
                  onNotification: (notification) {
                    FocusScope.of(context).unfocus();
                    return true;
                  },
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      // _focusNode.unfocus();
                      _editableTextState?.hideToolbar();

                      if (_messageController.selection.isValid) {
                        _messageController.selection = TextSelection.collapsed(
                            offset: _messageController.selection.extentOffset);
                      }
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
            // IconButton(
            //   icon: const Icon(Icons.mic),
            //   onPressed: () async {
            //     // TODO: 实现语音输入逻辑
            //   },
            // ),
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressUp: _stopRecording,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : null,
                ),
                child: Icon(_isRecording ? Icons.mic_off : Icons.mic,
                    color: _isRecording ? Colors.white : Colors.black),
              ),
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
            fit: FlexFit.loose,
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
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          minWidth: 0,
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
        final aspectRatio = _calculateAspectRatio(message);

        return _ImageBubbleWrapper(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: _getContentRadius(message),
            child: InkWell(
              onTap: () => _openImageDetail(context, message.content),
              child: Hero(
                tag: 'image_hero_${message.id}',
                child: Image.network(
                  message.content,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _ImageBubbleWrapper(
                      aspectRatio: aspectRatio,
                      child: _buildLoadingState(message, loadingProgress),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _ImageBubbleWrapper(
                      aspectRatio: aspectRatio,
                      child: _buildErrorState(message),
                    );
                  },
                ),
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
      case MessageType.audio:
        return _buildAudioBubbleContent(message);
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: SelectableLinkify(
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: message.senderId == currentUserId
                  ? Colors.white
                  : Colors.black87,
            ),
            linkStyle: TextStyle(
              fontSize: 16,
              color: message.senderId == currentUserId
                  ? Colors.white
                  : Colors.blue,
              decoration: TextDecoration.combine(
                [
                  TextDecoration.underline,
                ],
              ),
              decorationColor: message.senderId == currentUserId
                  ? Colors.white
                  : Colors.blue,
              decorationThickness: 1.5,
            ),
            options: LinkifyOptions(
              humanize: false,
              looseUrl: true,
            ),
            onOpen: (link) async {
              debugPrint('Clicked ${link.url}');
              if (!await launchUrlString(link.url)) {
                throw Exception('Could not launch ${link.url}');
              }
            },
            linkifiers: const [
              UrlLinkifier(),
              EmailLinkifier(),
            ],
            text: message.content,
            contextMenuBuilder: (context, editableTextState) {
              _editableTextState = editableTextState;
              final tempButtons = editableTextState.contextMenuButtonItems;
              final tempButtonCopy = tempButtons[0];
              final tempButtonShare = tempButtons[1];
              final tempButtonSelectAll = tempButtons[2];

              tempButtons.removeAt(0);
              tempButtons.removeAt(1);
              tempButtons.removeAt(2);

              tempButtons.addAll([
                ContextMenuButtonItem(
                  onPressed: tempButtonShare.onPressed,
                  type: tempButtonShare.type,
                  label: '分享',
                ),
                ContextMenuButtonItem(
                  onPressed: tempButtonSelectAll.onPressed,
                  type: tempButtonSelectAll.type,
                  label: '全选',
                ),
                ContextMenuButtonItem(
                  onPressed: tempButtonCopy.onPressed,
                  type: tempButtonCopy.type,
                  label: '复制',
                ),
              ]);

              return AdaptiveTextSelectionToolbar(
                anchors: editableTextState.contextMenuAnchors,
                children: [
                  ...tempButtons.reversed.map((item) {
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: item.onPressed,
                      child: Text(item.label ?? 'temp'),
                    );
                  }),
                ],
              );
            },
          ),
        );
    }
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
        // 用来测试发送失败
        // message.content = '';
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
      final imageFile = File(image.path);
      // 解码图片获取尺寸
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      final tempImage = ChatMessageItem(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        // 先占位
        content: '',
        timestamp: DateTime.now(),
        senderId: currentUserId,
        type: MessageType.image,
        status: MessageStatus.uploading,
        progress: 0,
        width: decodedImage?.width,
        height: decodedImage?.height,
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

  // 构建加载动画
  Widget _buildLoadingProgress(
      ImageChunkEvent progress, ChatMessageItem message) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width:
            message.width != null ? message.width as double : double.infinity,
        height: message.height != null ? message.height as double : 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.white,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  '加载中...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 计算图片宽高比的方法
  double _calculateAspectRatio(ChatMessageItem message) {
    if (message.width != null && message.height != null) {
      final w = message.width!.toDouble();
      final h = message.height!.toDouble();
      // return w > h ? w / h : h / w; // 保持比例在0.5-2之间
      return w / h;
    }
    return 1.0; // 默认正方形
  }

// 修改加载状态组件
  Widget _buildLoadingState(ChatMessageItem message, ImageChunkEvent progress) {
    return Stack(
      children: [
        // 背景骨架屏
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
        ),
        // 进度指示器
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '加载中...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// 修改上传状态组件
  Widget _buildUploadingState(ChatMessageItem message) {
    return _ImageBubbleWrapper(
      aspectRatio: _calculateAspectRatio(message),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.purple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: message.progress,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
                Icon(Icons.cloud_upload, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '上传中 ${(message.progress! * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

// 错误状态组件
  Widget _buildErrorState(ChatMessageItem message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[50]!, Colors.orange[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: Colors.red[400]),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _retryUpload(message),
            child: Text('重试上传', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 初始化录音模块
  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  // 开始录音
  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    try {
      // 检测设备存储权限
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('麦克风权限请求失败');
        _showToast('麦克风权限请求失败');
      }

      // 添加调试日志
      debugPrint('麦克风权限已获取：$status');

      // 新建临时文件夹
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
    } catch (e) {
      _showErrorSnackBar('开始录音失败：${e.toString()}');
      setState(() {
        _isRecording = false;
      });
    }
  }

  // 停止录音并发送录音
  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    try {
      final path = await _recorder.stopRecorder();
      _sendVoiceMessage(path!);
    } catch (e) {
      _showErrorSnackBar('录音失败：${e.toString()}');
    }
  }

  // 发送语音消息
  Future<void> _sendVoiceMessage(String localPath) async {
    // TODO: 实际需要实现云存储上传
    _uploadAudioToCloud(localPath);

    final newMessage = ChatMessageItem(
      // TODO: 后期对所有的消息 ID 进行统一编制
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.audio,
      // TODO: 替换为实际的云端音频 URL
      content: '',
      audioUrl:
          'https://example.com/audio/${DateTime.now().millisecondsSinceEpoch}',
      // TODO: 实际需要计算音频时长
      duration: Duration(seconds: 5),
      timestamp: DateTime.now(),
      senderId: currentUserId,
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
    });
  }

  // 播放暂停控制
  Future<void> _toggleAudioPlaying(ChatMessageItem message) async {
    // 当当前播放的语音消息的 ID 和当前消息 ID 相同，并且语音正在播放时，我们将暂停语音
    if (_currentAudioPlayingId == message.id && _isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isAudioPlaying = !_isAudioPlaying;
      });
    } else {
      // 判断后选择语音资源来源
      if (message.audioUrl.startsWith('http') ||
          message.audioUrl.startsWith('https')) {
        await _audioPlayer.play(UrlSource(message.audioUrl));
      } else {
        await _audioPlayer.play(DeviceFileSource(message.audioUrl));
      }
      setState(() {
        _currentAudioPlayingId = message.id;
        _isAudioPlaying = !_isAudioPlaying;
      });
    }
  }

  // 实现语音转文字功能
  Future<void> _transcribeAudio(ChatMessageItem message) async {
    // TODO: 实现真实的语音识别
    // 模拟转写结果
    setState(() {
      message.transcribedText =
          '这是模拟的语音转文字结果（${DateTime.now().millisecondsSinceEpoch}）';
    });
  }

  Widget _buildAudioBubbleContent(ChatMessageItem message) {
    bool isMe = currentUserId == message.senderId;
    final isCurrentPlaying =
        _currentAudioPlayingId == message.id && _isAudioPlaying;
    final maxWidth = MediaQuery.of(context).size.width * 0.5;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isCurrentPlaying ? Icons.pause : Icons.play_arrow),
                color: isMe ? Colors.white : Colors.blue,
                onPressed: () => _toggleAudioPlaying(message),
              ),
              Text(
                '${message.duration.inSeconds}秒',
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          if (message.transcribedText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.transcribedText!,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.translate,
                  color: isMe ? Colors.white54 : Colors.blueGrey),
              iconSize: 18,
              onPressed: () => _transcribeAudio(message),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: 实现云存储上传
  Future<String> _uploadAudioToCloud(String localPath) async {
    await Cos().initWithPlainSecret(_secretId, _secretKey);
    // 腾讯云存储通的区域
    String region = 'ap-beijing';
    // =========== 注册 COS 服务 ===========
    // 创建 CosXmlServiceConfig 对象，根据需要修改默认的参数配置
    CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: region,
      isDebuggable: true,
      isHttps: true,
    );

    // 注册默认 Cos Service
    await Cos().registerDefaultService(serviceConfig);
    // 创建 TransferConfig 对象，根据需要修改默认的配置参数
    TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      // 设置大于等于 2M 的文件进行分块上传
      divisionForUpload: 2097152,
      // 设置默认分块大小为 1M
      sliceSizeForUpload: 1048576,
    );

    // 注册默认 COS TransferManager
    await Cos().registerDefaultTransferManger(serviceConfig, transferConfig);

    // =========== 访问 COS 服务 ===========
    // 获取 TransferManager
    CosTransferManger transferManger = Cos().getDefaultTransferManger();
    // 存储桶名称
    String bucket = _voiceBucket;
    // 对象在存储桶中的为i饿汉子标识符，即对象键
    String cosPath =
        'tiny_stack_voice_chat_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';

    // 若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则复制 null
    String? _uploadId = cosPath;

    // 上传成功回调
    successCallBack(Map<String?, String?>? hander, CosXmlResult? result) {
      // TODO: 上传成功后的逻辑
    }

    // 上传失败回调
    failCallBack(clientException, serviceException) {
      // TODO: 上传失败后的逻辑
      if (clientException != null) {
        debugPrint('客户端语音消息上传失败 ${clientException.toString()}');
      }
      if (serviceException != null) {
        debugPrint('服务端语音消息上传失败 ${clientException.toString()}');
      }
    }

    // 上传状态回调，可以查看任务过程
    stateCallBack(state) {
      // TODO: 通知传输状态
    }

    // 上传进度回调
    progressCallBack(complete, target) {
      // TODO: 上传进度逻辑
    }

    // 初始化分块完成回调
    initMultipleUploadCallBack(String bucket, String cosKey, String uploadId) {
      // 用户下次续传上传的 uploadId
      _uploadId = uploadId;
    }

    // 开始上传
    TransferTask transferTask = await transferManger.upload(
      bucket,
      cosPath,
      filePath: localPath,
      uploadId: _uploadId,
      resultListener: ResultListener(successCallBack, failCallBack),
      progressCallBack: progressCallBack,
      initMultipleUploadCallback: initMultipleUploadCallBack,
    );
    return '';
  }

  // TODO: 实现真实的语音识别
  Future<String> _transcribe(String audioUrl) async {
    return '模拟转写结果';
  }

  // TODO: 实现对于音频时长的计算
  Duration _calculateAudioDuration(String filePath) {
    return Duration(seconds: 5);
  }
}

// 统一尺寸包装组件
class _ImageBubbleWrapper extends StatelessWidget {
  final double aspectRatio;
  final Widget child;

  const _ImageBubbleWrapper({
    required this.aspectRatio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: child,
      ),
    );
  }
}
