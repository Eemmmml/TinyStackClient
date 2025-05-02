import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinystack/entity/chat_message_item.dart';
import 'package:tinystack/managers/audio_player_provider.dart';

class AudioMessageBubble extends StatefulWidget {
  final ChatMessageItem message;
  final String currentUserId;

  const AudioMessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  // 音频播放器
  late AudioPlayer _audioPlayer;

  // 音频播放进度
  // double _audioProgress = 0.0;

  // 音频是否在播放音频
  // bool _isAudioPlaying = false;

  // 当前播放音频的 ID
  // String? _currentAudioPlayingId;

  // 文字展开状态
  bool _isTranscriptionExpanded = false;

  // 语音转文字工具 final sst.SpeechToText _speech = sst.SpeechToText();

  @override
  void initState() {
    super.initState();
    // 初始化音频播放器
    final audioPlayer = context.read<AudioPlayerProvider>();
    audioPlayer.initPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 切换音频播放状态
  void _toggleAudioPlaying(ChatMessageItem message) async {
    final audioPlayer = context.read<AudioPlayerProvider>();
    try {
      audioPlayer.toggleAudioPlayingState(message.id, message.audioUrl);
    } catch (e) {
      debugPrint('播放错误: $e');
      _stopAudio();
    }
  }

  // 停止播放语音
  void _stopAudio() {
    final audioPlayer = context.read<AudioPlayerProvider>();
    audioPlayer.stop();
  }

  // 展示语音转文字菜单
  void _showTranscribeMenu(ChatMessageItem message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('语音转文字'),
              onTap: () {
                Navigator.pop(context);
                _transcribeAudio(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除消息'),
              onTap: () => _deleteMessage(message),
            ),
          ],
        ),
      ),
    );
  }

  void _transcribeAudio(ChatMessageItem message) async {
    setState(() {
      _isTranscriptionExpanded = true;
    });
    debugPrint(message.transcribedText);
  }

  void _deleteMessage(ChatMessageItem message) {
    // TODO: 实现删除消息逻辑
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.currentUserId == widget.message.senderId;
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.5;
    final audioPlayer = context.watch<AudioPlayerProvider>();

    return Column(
      children: [
        // 原始语音气泡
        GestureDetector(
          onTap: () => _toggleAudioPlaying(widget.message),
          onLongPress: () => _showTranscribeMenu(widget.message),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxBubbleWidth,
              minHeight: 16,
            ),
            decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade300 : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Consumer(builder: (context, provider, child) {
                      return CustomPaint(
                        painter: _AudioBubbleProgressPainter(
                          progress: audioPlayer.audioProgress,
                          activeColor:
                              isMe ? Colors.blue.shade800 : Colors.grey[400]!,
                          backgroundColor:
                              isMe ? Colors.blue.shade300 : Colors.grey[300]!,
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Consumer<AudioPlayerProvider>(
                    builder: (context, provider, child) {
                      // final isCurrentPlaying =
                      //     provider.currentAudioId == widget.message.id && provider.isAudioPlaying;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                                (provider.currentAudioId == widget.message.id &&
                                        provider.isAudioPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: isMe ? Colors.white : Colors.blue,
                                size: 24,
                                key: ValueKey(provider.currentAudioId ==
                                        widget.message.id &&
                                    provider.isAudioPlaying)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _AudioWaveForm(
                                      duration: widget.message.duration,
                                      progress: audioPlayer.audioProgress,
                                      playedColor:
                                          isMe ? Colors.white : Colors.blue,
                                      unplayedColor: Colors.grey[300]!,
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                Positioned(
                                  right: 1,
                                  child: Text(
                                    '${widget.message.duration.inSeconds}秒',
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       AnimatedSwitcher(
                //         duration: const Duration(milliseconds: 200),
                //         child: Icon(
                //             isCurrentPlaying ? Icons.pause : Icons.play_arrow,
                //             color: isMe ? Colors.white : Colors.blue,
                //             size: 24,
                //             key: ValueKey(isCurrentPlaying)),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: Stack(
                //           children: [
                //             Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 _AudioWaveForm(
                //                   duration: widget.message.duration,
                //                   progress: _audioProgress,
                //                   playedColor:
                //                       isMe ? Colors.white : Colors.blue,
                //                   unplayedColor: Colors.grey[300]!,
                //                 ),
                //                 const SizedBox(height: 4),
                //               ],
                //             ),
                //             Positioned(
                //               right: 1,
                //               child: Text(
                //                 '${widget.message.duration.inSeconds}秒',
                //                 style: TextStyle(
                //                   color:
                //                       isMe ? Colors.white70 : Colors.blueGrey,
                //                   fontSize: 12,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                if (widget.message.transcribedText == null ||
                    widget.message.transcribedText!.isEmpty)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: () => _transcribeAudio(widget.message),
                      child: Icon(
                        Icons.translate,
                        color: isMe ? Colors.white54 : Colors.blueGrey,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 语音转录文字部分
        if (widget.message.transcribedText != null &&
            widget.message.transcribedText!.isNotEmpty &&
            _isTranscriptionExpanded)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxBubbleWidth,
              ),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black12,
                //     blurRadius: 4,
                //     offset: const Offset(0, 2),
                //   ),
                // ]
              ),
              child: Column(
                children: [
                  Text(
                    widget.message.transcribedText!,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isTranscriptionExpanded = false;
                    }),
                    child: Icon(
                      _isTranscriptionExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isMe ? Colors.white : Colors.blue,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// 构建语音播放进度
class _AudioBubbleProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;
  Shader? _cachedShader;
  Rect? _cachedRect;
  List<Color>? _cachedColors;

  _AudioBubbleProgressPainter(
      {required this.progress,
      required this.activeColor,
      required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;

    // 获取当前颜色配置
    final currentColors = [activeColor, activeColor.withOpacity(0.7)];
    final currentRect = Rect.fromLTRB(0, 0, size.width, size.height);

    // 判断是否需要更新 Shader
    if (_cachedShader == null ||
        _cachedRect != currentRect ||
        !_colorsEqual(currentColors, _cachedColors)) {
      _cachedShader = LinearGradient(
              colors: currentColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(currentRect);
      _cachedRect = currentRect;
      _cachedColors = currentColors;
    }

    final progressPaint = Paint()..shader = _cachedShader;

    // 绘制背景
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        currentRect,
        const Radius.circular(12),
      ),
      backgroundPaint,
    );

    // 绘制进度条
    final progressRect =
        Rect.fromLTWH(0, 0, size.width * progress, size.height);
    if (progress > 0) {
      canvas.saveLayer(progressRect, Paint());
      canvas.drawRRect(
        RRect.fromRectAndRadius(progressRect, const Radius.circular(12)),
        progressPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _AudioBubbleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }

  // 颜色列表比较方法
  bool _colorsEqual(List<Color>? a, List<Color>? b) {
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value) return false;
    }
    return true;
  }
}

// 音频波形
class _AudioWaveForm extends StatelessWidget {
  final Duration duration;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;

  const _AudioWaveForm({
    required this.duration,
    required this.progress,
    this.playedColor = Colors.white,
    this.unplayedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final waveformHeights = _generateWaveformData(duration);

    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: _WaveFromPainter(
          waveFromHeights: waveformHeights,
          progress: progress,
          playedColor: playedColor,
          unplayedColor: unplayedColor,
        ),
      ),
    );
  }

  // 采集波形数据点
  List<double> _generateWaveformData(Duration duration) {
    // 最大数据点数
    const maxDataPoints = 15;
    final totalSeconds = duration.inSeconds;

    // 动态计算需要的采样点数
    int dataPointCount = totalSeconds.clamp(1, maxDataPoints);

    // 生成时间标记点
    return List.generate(dataPointCount, (index) {
      // 均匀分布的时间点
      final timePosition = duration * (index / dataPointCount);

      // 模拟真实波形分析（实际应使用音频分析库）
      return _simulateAudioPeak(timePosition);
    });
  }

  // 音频波形分析
  double _simulateAudioPeak(Duration position) {
    final seed = position.inMilliseconds % 100;
    final random = Random(seed);

    double baseHeight = random.nextDouble();
    baseHeight += sin(position.inMilliseconds * 0.01) * 0.2;

    return baseHeight.clamp(0.3, 1.0);
  }
}

// 波形绘制器
class _WaveFromPainter extends CustomPainter {
  final List<double> waveFromHeights;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;

  _WaveFromPainter({
    required this.waveFromHeights,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barSpacing = 4;
    final totalBars = waveFromHeights.length;
    final barWidth = 2.0;
    final progressIndex = (totalBars * progress).floor();

    for (var i = 0; i < waveFromHeights.length; i++) {
      final paint = Paint()
        ..color = i <= progressIndex ? playedColor : unplayedColor
        ..style = PaintingStyle.fill;

      final height = waveFromHeights[i] * size.height;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((i) * (barWidth + barSpacing),
              (size.height - height) / 2, barWidth - 4, height),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
