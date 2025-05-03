import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image_plus/flutter_cached_network_image_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinystack/entity/group_item.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../entity/chat_item.dart';
import '../../entity/chat_message_item.dart';
import '../../provider/audio_player_provider.dart';
import '../../utils/audio_text_handle_utils.dart';
import '../../utils/cloud_upload_utils.dart';
import 'audio_message_bubble.dart';
import 'group_info_page.dart';
import 'image_detail_screen.dart';
import 'video_recorder_page.dart';

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

  // 音频录音器
  late final RecorderController _recorderController;

  // 音频播放控制器
  late final PlayerController _playerController;

  // 语音播放器
  // final AudioPlayer _audioPlayer = AudioPlayer();

  // 语音转文字工具
  final AudioTextHandleUtils _audioTextHandleUtils = AudioTextHandleUtils();

  // 是否展示录音界面
  bool _showRecordingUI = false;

  // 用来强制加载状态的变量
  bool tempState = false;

  // 录音状态
  bool _isRecording = false;

  // 音频播放状态
  // bool _isAudioPlaying = false;

  //文字阅读状态
  bool _isTextReading = false;

  // 录音时长
  int _recordedSeconds = 0;

  // 计时器
  Timer? _recordingTimer;

  // 当前播放音频的 ID
  // String? _currentAudioPlayingId;

  // 当前阅读的文本消息的 ID
  String? _currentReadingTextId;

  // TODO: 将永久密钥替换为获取的临时密钥
  // 腾讯云 SecretId
  final String _secretId = 'AKIDIVZQ2PXR5UhmhRyINGvOdcPyINDoAIAQ';

  // 腾讯云 SecretKey
  final String _secretKey = '70f5HI6lOo0xFOJzRjrnUzHNK7jDj9OQ';

  // 音频腾讯云存储桶名称
  final String _voiceBucket = 'tinystack-voice-store-1356865752';

  // 图片腾讯云存储桶名称
  final String _imageBucket = 'tinystack-image-store-1356865752';

  // 视频腾讯云存储桶名称
  final String _videoBucket = 'tinystack-video-store-1356865752';

  // 腾讯云存储桶的服务器区域
  final String _region = 'ap-beijing';

  // 音频上传工具
  late CloudUploadUtils _audioCloudUploadUtils;

  // 图片上传工具
  late CloudUploadUtils _imageCloudUploadUtils;

  // 视频上传工具
  late CloudUploadUtils _videoCloudUploadUtils;

  @override
  void initState() {
    super.initState();
    _messages.addAll(mockMessages);
    // 初始化录音控制器
    _initRecorder();
    // _audioPlayer.onPlayerComplete.listen((_) {
    //   setState(() {
    //     _isAudioPlaying = false;
    //     _isTextReading = false;
    //     _currentReadingTextId = null;
    //     _currentAudioPlayingId = null;
    //   });
    // });
    final audioPlayer = context.read<AudioPlayerProvider>();
    audioPlayer.initPlayer();

    _audioCloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _voiceBucket,
        region: _region);

    _videoCloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _videoBucket,
        region: _region);

    _imageCloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _imageBucket,
        region: _region);
    // 为滚动控制器添加监听器
    _scrollController.addListener(() {
      setState(() {
        _showRecordingUI = false;
      });
    });

    // 初始化录音波形控制器
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;

    // 初始化播放波形控制器
    _playerController = PlayerController();

    // 添加焦点变化监听器
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    // 销毁录音控制器
    _recorder.closeRecorder();
    // 销毁音频播放器
    // _audioPlayer.dispose();
    super.dispose();
  }

  // 处理焦点变化逻辑
  void _handleFocusChange() {
    if (_focusNode.hasFocus && _showRecordingUI) {
      setState(() {
        _showRecordingUI = false;
      });
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessageItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: text,
        timestamp: DateTime.now(),
        senderId: currentUserId,
        type: MessageType.text);

    // String ttsAudioUrl = await _audioTextHandleUtils.readText(newMessage);
    // debugPrint('语音路径: $ttsAudioUrl');
    //
    // newMessage.ttsAudioUrl = ttsAudioUrl;

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // 滚动到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageWithGroups = _getMessageWithTimeGroups().reversed.toList();

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
                    setState(() {
                      _showRecordingUI = false;
                    });
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
                        controller: _scrollController,
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

        if (_showRecordingUI) _buildRecordingUI(),
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
                // TODO: 实现开关录音界面状态
                FocusScope.of(context).unfocus();
                setState(() {
                  _showRecordingUI = !_showRecordingUI;
                });
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
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: () async {
                // TODO: 实现视频发送逻辑
                try {
                  final result = await VideoRecorderPage.navigate(context);

                  String? photoPath = result['photoPath'];
                  String? videoPath = result['videoPath'];
                  String? thumbnailPath = result['thumbnailPath'];

                  if (photoPath != null) {
                    _sendPhotoMessage(photoPath);
                  } else if (videoPath != null && thumbnailPath != null) {
                    _sendVideoMessage(videoPath, thumbnailPath);
                  }

                  debugPrint(
                      '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}:\nvideoPath: $videoPath\nthumbnailPath: $thumbnailPath\nphotoPath: $photoPath');
                } catch (e) {
                  debugPrint('VideoError: $e');
                }
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
    // 对消息队列进行排序
    _messages.sort((msg1, msg2) {
      if (msg1.timestamp.isBefore(msg2.timestamp)) {
        return -1;
      } else if (msg1.timestamp.isAfter(msg2.timestamp)) {
        return 1;
      } else {
        return 0;
      }
    });

    List<dynamic> results = [];

    // 上一次的消息发送时间
    DateTime? previousTimeStamp;

    for (var msg in _messages) {
      if (previousTimeStamp == null ||
          msg.timestamp.difference(previousTimeStamp).inMinutes > 5) {
        results.add(_createTimeGroup(msg.timestamp));
        previousTimeStamp = msg.timestamp;
      }
      results.add(msg);
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMe) _buildMessageAvatar(message, isMe),
          if (!isMe) const SizedBox(width: 4),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: _buildHeaderRowChildren(isMe, message),
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

  // 构建消息头部
  List<Widget> _buildHeaderRowChildren(bool isMe, ChatMessageItem message) {
    final ttsButton = _buildTTSButton(message);

    return [
      if (isMe && message.type == MessageType.text) ttsButton,
      if (widget.currentChat.isGroup)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            message.senderName,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      if (!isMe && message.type == MessageType.text) ttsButton,
    ];
  }

  // 提取公共按钮组件方法
  Widget _buildTTSButton(ChatMessageItem message) {
    final audioPlayer = context.watch<AudioPlayerProvider>();
    return Consumer<AudioPlayerProvider>(
      builder: (context, provider, child) {
        debugPrint('bool1: ${audioPlayer.isTextReading}');
        debugPrint(
            'bool2: ${audioPlayer.isTextReading && audioPlayer.currentReadingTextId == message.id}');
        return IconButton(
          onPressed: () => audioPlayer.isTextReading
              ? _stopTextToSpeech(message)
              : _playTextToSpeech(message),
          icon: Icon(Icons.volume_up,
              size: 20,
              color: (audioPlayer.isTextReading &&
                      audioPlayer.currentReadingTextId == message.id)
                  ? Colors.blue
                  : Colors.grey),
          style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(32, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              )),
        );
      },
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
        child: Stack(
          clipBehavior: Clip.none,
          alignment: isMe ? Alignment.topLeft : Alignment.topRight,
          children: [
            Container(
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
          ],
        ));
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
        final BorderRadius radius = _getContentRadius(message);

        return _BubbleWrapper(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: radius,
            child: InkWell(
              onTap: () => _openImageDetail(context, message.content),
              child: Hero(
                tag: 'image_hero_${message.id}',
                child: CacheNetworkImagePlus(
                  borderRadius: radius,
                  imageUrl: message.content,
                  boxFit: BoxFit.cover,
                  errorWidget: _BubbleWrapper(
                      aspectRatio: aspectRatio,
                      child: _buildRetryState(message)),
                  boxDecoration: BoxDecoration(
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
        );
      case MessageType.video:
        if (message.status == MessageStatus.uploading) {
          // 上传中的状态
          return _buildUploadingState(message);
        }

        final aspectRatio = _calculateAspectRatio(message);
        final BorderRadius radius = _getContentRadius(message);
        return ClipRRect(
          borderRadius: _getContentRadius(message),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _BubbleWrapper(
                aspectRatio: aspectRatio,
                child: ClipRRect(
                  borderRadius: radius,
                  child: InkWell(
                    onTap: () => _openImageDetail(context, message.content),
                    child: Hero(
                      tag: 'image_hero_${message.id}',
                      child: CacheNetworkImagePlus(
                        borderRadius: radius,
                        imageUrl: message.content.isNotEmpty
                            ? message.content
                            : 'https://picsum.photos/120/90?random=4',
                        boxFit: BoxFit.cover,
                        errorWidget: _BubbleWrapper(
                            aspectRatio: aspectRatio,
                            child: _buildErrorState(message)),
                        boxDecoration: BoxDecoration(
                          borderRadius: radius,
                        ),
                      ),
                    ),
                  ),
                ),
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
        // return _buildAudioBubbleContent(message);
        return AudioMessageBubble(
            message: message, currentUserId: currentUserId);
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

  // 实际图片上传过程
  void _uploadImage(File file, ChatMessageItem message) async {
    _imageCloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _imageBucket,
        region: _region,
        progressCallBack: (complete, target) {
          // 实际的上传进度
          setState(() {
            message.progress = complete / target;
          });
        });

    try {
      final cosPath =
          'tiny_stack_image_chat${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
      final uploaderId = currentUserId;

      final imageUrl = await _imageCloudUploadUtils.uploadLocalFileToCloud(
          file.path, cosPath, uploaderId);

      // if (await file.exists()) {
      //   file.delete();
      // }

      // 等待一段时间来保证腾讯云 COS 服务正确同步我们上传的数据
      await Future.delayed(const Duration(milliseconds: 2000));
      setState(() {
        // 替换为真实云端 URL
        message.content = imageUrl;
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
    _imageCloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _imageBucket,
        region: _region,
        progressCallBack: (complete, target) {
          // 实际的上传进度
          setState(() {
            message.progress = complete / target;
          });
        });
    final cosPath =
        'tiny_stack_image_chat${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
    final uploaderId = currentUserId;

    final imageUrl = await _imageCloudUploadUtils.uploadLocalFileToCloud(
        imageFile.path, cosPath, uploaderId);

    await Future.delayed(const Duration(milliseconds: 1000));
    return imageUrl;
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

      // _mockUploadImage(File(image.path), tempImage);
      _uploadImage(File(image.path), tempImage);

      setState(() {
        _messages.add(tempImage);
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
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
    return _BubbleWrapper(
      aspectRatio: _calculateAspectRatio(message),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _getContentRadius(message),
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

// 错误状态组件
  Widget _buildRetryState(ChatMessageItem message) {
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
            onPressed: () {
              setState(() {
                message.key = '1';
              });
            },
            child: Text('重试加载', style: TextStyle(color: Colors.red)),
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
      _recordedSeconds = 0;
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

      // await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
      // 使用 audio_waveforms 进行录音
      await _recorderController.record(path: filePath);

      // 启动计时器
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordedSeconds++;
        });

        // 达到 120 秒自动停止
        if (_recordedSeconds >= 120) {
          _stopRecording();
        }
      });
    } catch (e) {
      _showErrorSnackBar('开始录音失败：${e.toString()}');
      setState(() {
        _isRecording = false;
      });
    }
  }

  // 停止录音并发送录音
  Future<void> _stopRecording() async {
    // 取消计时器
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      // final path = await _recorder.stopRecorder();
      // 停止录音并获取路径
      final path = await _recorderController.stop();
      if (path != null) {
        _sendVoiceMessage(path);
      }
    } catch (e) {
      _showErrorSnackBar('录音失败：${e.toString()}');
    } finally {
      setState(() {
        _isRecording = false;
        _recordedSeconds = 0;
      });
    }
  }

  // 发送语音消息
  Future<void> _sendVoiceMessage(
    String localPath,
  ) async {
    // TODO: 实际需要实现云存储上传
    // String audioUrl = await _uploadAudioToCloud(localPath);
    final cosPath =
        'tiny_stack_voice_chat_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
    final uploaderId = currentUserId;
    String audioUrl = await _audioCloudUploadUtils.uploadLocalFileToCloud(
        localPath, cosPath, uploaderId);

    String transcribedText =
        await _audioTextHandleUtils.recognizeAudio(localPath);

    final audioFile = File(localPath);
    // if (await audioFile.exists()) {
    //   audioFile.delete();
    // }

    final newMessage = ChatMessageItem(
      // TODO: 后期对所有的消息 ID 进行统一编制
      id: cosPath,
      type: MessageType.audio,
      // 替换为实际的云端音频 URL
      content: '',
      audioUrl: audioUrl,
      // 计算音频时长
      duration: await _calculateAudioDuration(audioUrl),
      timestamp: DateTime.now(),
      senderId: currentUserId,
      status: MessageStatus.sent,
      transcribedText: transcribedText,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // 滚动到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // 发送摄影的视频消息
  Future<void> _sendVideoMessage(String videoPath, String thumbnailPath) async {
    final videoCosPath =
        'tiny_stack_shot_video_chat_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
    final thumbnailCosPath =
        'tiny_stack_video_thumbnail_chat_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
    final videoFile = File(videoPath);
    final thumbnailFile = File(thumbnailPath);

    final newMessage = ChatMessageItem(
        id: videoCosPath,
        content: '',
        timestamp: DateTime.now(),
        status: MessageStatus.uploading,
        type: MessageType.video,
        senderId: currentUserId);

    setState(() {
      _messages.add(newMessage);
    });

    final thumbnailUrl = await _uploadImageToCloud(thumbnailFile, newMessage);
    // final thumbnailUrl = await _imageCloudUploadUtils.uploadLocalFileToCloud(
    //     thumbnailPath, thumbnailCosPath, newMessage.id);
    final videoUrl = await _videoCloudUploadUtils.uploadLocalFileToCloud(
        videoPath, videoCosPath, newMessage.id);

    // // 删除本地文件
    // if (await videoFile.exists()) {
    //   videoFile.delete();
    // }
    //
    // if (await thumbnailFile.exists()) {
    //   thumbnailFile.delete();
    // }

    // 滚动到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    await Future.delayed(const Duration(milliseconds: 5000));
    setState(() {
      newMessage.content = thumbnailUrl;
      newMessage.videoUrl = videoUrl;
      newMessage.status = MessageStatus.sent;
    });
  }

  // 发送照片的消息
  Future<void> _sendPhotoMessage(String photoPath) async {
    final cosPath =
        'tiny_stack_shot_photo_chat_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';

    final newMessage = ChatMessageItem(
        id: cosPath,
        content: '',
        timestamp: DateTime.now(),
        status: MessageStatus.uploading,
        type: MessageType.image,
        senderId: currentUserId);

    _imageCloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _imageBucket,
        region: _region,
        progressCallBack: (complete, target) {
          // 实际的上传进度
          setState(() {
            newMessage.progress = complete / target;
          });
        },
        successCallBack: (handler, result) {
          debugPrint('success Result: ${result.toString()}');
        });

    try {
      setState(() {
        _messages.add(newMessage);
      });

      final photoUrl = await _imageCloudUploadUtils.uploadLocalFileToCloud(
          photoPath, cosPath, newMessage.id);

      await Future.delayed(const Duration(milliseconds: 4000));
      setState(() {
        newMessage.content = photoUrl;
        newMessage.status = MessageStatus.sent;
      });

      debugPrint('PhotoUrl: $photoUrl');

      // final photoFile = File(photoPath);
      // // 删除本地文件
      // if (await photoFile.exists()) {
      //   photoFile.delete();
      // }
    } catch (e) {
      setState(() {
        newMessage.status = MessageStatus.failed;
        debugPrint('照片上传失败：$e');
      });
    }

    // 滚动到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // 播放暂停控制
  Future<void> _toggleAudioPlaying(ChatMessageItem message) async {
    final audioPlayer = context.read<AudioPlayerProvider>();

    // 当当前播放的语音消息的 ID 和当前消息 ID 相同，并且语音正在播放时，我们将暂停语音
    if (audioPlayer.currentAudioId == message.id &&
        audioPlayer.isAudioPlaying) {
      await audioPlayer.pauseAudio();
    } else {
      audioPlayer.toggleAudioPlayingState(message.id, message.audioUrl);
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
    final audioPlayer = context.read<AudioPlayerProvider>();
    bool isMe = currentUserId == message.senderId;
    final isCurrentPlaying =
        audioPlayer.currentAudioId == message.id && audioPlayer.isAudioPlaying;
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
          // 播放控制 + 波形
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isCurrentPlaying ? Icons.pause : Icons.play_arrow),
                color: isMe ? Colors.white : Colors.blue,
                onPressed: () => _toggleAudioPlaying(message),
              ),
              Expanded(
                child: AudioFileWaveforms(
                  size: Size(200, 20),
                  playerController: _playerController,
                  waveformType: WaveformType.long,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: isMe ? Colors.white54 : Colors.grey[200]!,
                    liveWaveColor: isMe ? Colors.white : Colors.blue,
                  ),
                ),
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

  // TODO: 实现对于音频时长的计算
  Future<Duration> _calculateAudioDuration(String audioUrl) async {
    final player = AudioPlayer();
    try {
      await player.setSourceUrl(audioUrl);
      final duration = await player.getDuration();
      return duration ?? Duration.zero;
    } catch (e) {
      debugPrint(
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())} Error calculating audio duration: $e');
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  // 构建录音界面
  Widget _buildRecordingUI() {
    final minutes = (_recordedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordedSeconds % 60).toString().padLeft(2, '0');

    return Container(
      height: 290,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 显示录音时长
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTapDown: (_) => _startRecording(),
            onLongPressUp: () => _stopRecording(),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.grey[200],
              ),
              child: Icon(Icons.mic,
                  size: 56, color: _isRecording ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            _isRecording ? '松开结束录音' : '按住说话',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<bool> setTextReadingResourceWithRetry(String url,
      {int? maxRetries, Duration? timeout}) async {
    final audioPlay = context.read<AudioPlayerProvider>();
    final encodeUrl = Uri.encodeFull(url);
    final retryOptions = RetryOptions(
      // 最多重试次数
      maxAttempts: maxRetries ?? 1,
      // 重试间隔
      delayFactor: Duration(seconds: 1),
    );

    try {
      await retryOptions.retry(
        () async {
          await audioPlay.setAudioSource(encodeUrl, Duration(seconds: 1));
        },
        retryIf: (e) => _isRetryAbleError(e),
      );
      return true;
    } catch (e) {
      debugPrint('音频资源加载失败');
      return false;
    }
  }

  // 判断是否可重试的错误类型
  bool _isRetryAbleError(dynamic error) {
    return error is SocketException ||
        error is HttpException ||
        error is TimeoutException;
  }

  // 文字转语音播放方法
  void _playTextToSpeech(ChatMessageItem message) async {
    debugPrint('启动文字转语音服务');
    final audioPlayer = context.read<AudioPlayerProvider>();

    // 暂停已播放的语音
    debugPrint('正在暂停播放中的语音');
    await audioPlayer.stop();

    debugPrint('正在更新状态');
    setState(() {
      audioPlayer.isAudioPlaying = false;
      audioPlayer.isTextReading = true;
      _isTextReading = true;
      audioPlayer.currentReadingTextId = message.id;
    });

    try {
      // 在这里处理文字转语音的懒加载逻辑
      String ttsAudioUrl = '';
      if (message.ttsAudioUrl.isEmpty) {
        // 当文字语音没有加载，开始加载语音
        debugPrint('开始生成语音');
        ttsAudioUrl = await _audioTextHandleUtils.readText(message);
        message.ttsAudioUrl = ttsAudioUrl;

        _stopTextToSpeech(message);
        _showToast('正在生成语音资源，请稍后再次点击播放');

        return;
      } else {
        // 当文字语音已经加载，直接使用语音
        ttsAudioUrl = message.ttsAudioUrl;
      }

      // 播放文字转语音的语音
      debugPrint('正在播放语音：$ttsAudioUrl');
      // 设置语音资源
      final canPlay = await setTextReadingResourceWithRetry(ttsAudioUrl);
      // 根据是否可以播放语音来采用不同的策略
      if (canPlay) {
        // 恢复语音播放
        await audioPlayer.resumeReading();
      } else {
        _stopTextToSpeech(message);
        _showErrorSnackBar('音频资源加载失败，请重试');
      }
    } catch (e) {
      debugPrint('文字转语音播放错误：$e');
    }
  }

  // 文字语音暂停方法
  void _stopTextToSpeech(ChatMessageItem message) async {
    debugPrint('停止文字转语音服务');
    final audioPlayer = context.read<AudioPlayerProvider>();
    setState(() {
      _isTextReading = false;
      audioPlayer.isTextReading = false;
      audioPlayer.currentReadingTextId = null;
    });

    try {
      // 暂停已播放的语音
      await audioPlayer.stop();
    } catch (e) {
      debugPrint('文字转语音暂停错误：$e');
    }
  }
}

// 统一尺寸包装组件
class _BubbleWrapper extends StatefulWidget {
  final double aspectRatio;
  final Widget child;

  const _BubbleWrapper({
    required this.aspectRatio,
    required this.child,
  });

  @override
  State<_BubbleWrapper> createState() => _BubbleWrapperState();
}

class _BubbleWrapperState extends State<_BubbleWrapper> {
  UniqueKey key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: widget.child,
      ),
    );
  }
}
