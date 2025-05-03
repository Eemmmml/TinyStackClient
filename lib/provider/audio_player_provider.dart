import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioId;
  String? _currentReadingTextId;
  bool _isAudioPlaying = false;
  bool _isTextReading = false;
  double _audioProgress = 0.0;

  // 获取音频播放进度
  double get audioProgress => _audioProgress;

  // 获取音频播放器
  AudioPlayer get player => _audioPlayer;

  // 获取当前播放音频 ID
  String? get currentAudioId => _currentAudioId;

  // 获取当前阅读文本的 ID
  String? get currentReadingTextId => _currentReadingTextId;

  // 获取当前音频播放状态
  bool get isAudioPlaying => _isAudioPlaying;

  // 获取当前文本阅读状态
  bool get isTextReading => _isTextReading;

  set currentAudioId(String? audioId) {
    _currentAudioId = audioId;
    notifyListeners();
  }

  set currentReadingTextId(String? textId) {
    _currentReadingTextId = textId;
    notifyListeners();
  }

  set isAudioPlaying(bool playing) {
    _isAudioPlaying = playing;
    notifyListeners();
  }

  set isTextReading(bool reading) {
    _isTextReading = reading;
    notifyListeners();
  }

  // 初始化播放器
  void initPlayer() {
    // _audioPlayer.onPlayerStateChanged.listen((state) {
    //   if (state == PlayerState.stopped && _isAudioPlaying) {
    //     stop();
    //   }
    // });
    //
    // _audioPlayer.onPlayerComplete.listen((_) => stop());

    // 初始化音频播放器
    _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    // 音频播放器播放状态变化监听
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.stopped && isAudioPlaying) {
        stop();
      }
    });

    // 音频播放器播放位置监听
    _audioPlayer.onPositionChanged.listen((Duration position) async {
      final duration = await _audioPlayer.getDuration();
      if (duration == null || duration.inMilliseconds == 0) return;

      final newProgress = position.inMilliseconds / duration.inMilliseconds;
      if (newProgress >= 1.0) {
        await stop();
      } else {
        if (isAudioPlaying) {
          _audioProgress = newProgress;
          notifyListeners();
        }
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) => stop());
  }

  // 销毁音频播放器
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 播放音频
  Future<void> toggleAudioPlayingState(String audioId, String audioUrl) async {
    // 当播放的音频为当前音频时，暂停音频播放
    if (currentAudioId == audioId && isAudioPlaying) {
      await pauseAudio();
      return;
    }

    if (currentAudioId == audioId && !isAudioPlaying) {
      await resumeAudioPlaying();
      return;
    }

    // 当播放的音频不是当前音频时，先停止播放
    if (currentAudioId != null) {
      await stop();
    }

    try {
      // 判断后选择语音资源来源
      if (audioUrl.startsWith('http') || audioUrl.startsWith('https')) {
        // 播放新的语音
        await _audioPlayer.play(UrlSource(audioUrl));
      } else {
        // 播放新的语音
        await _audioPlayer.play(DeviceFileSource(audioUrl));
      }
      currentAudioId = audioId;
      currentReadingTextId = null;
      isAudioPlaying = true;
      isTextReading = false;
      notifyListeners();
    } catch (e) {
      stop();
      debugPrint('音频播放失败：$e');
    }
  }

  // // 播放文本语音
  // Future<void> toggleTextReadingState(String textId, String audioUrl) async {
  //   // 当播放的音频为当前音频时，暂停音频播放
  //   _audioProgress = 0.0;
  //   if (currentReadingTextId == textId && isTextReading) {
  //     // await pauseReading();
  //     await stop();
  //     return;
  //   }
  //
  //   // 当播放的音频不是当前音频时，先停止播放
  //   if (currentReadingTextId != null) {
  //     await stop();
  //   }
  //
  //   try {
  //     currentReadingTextId = textId;
  //     currentAudioId = null;
  //     isTextReading = true;
  //     isAudioPlaying = false;
  //     notifyListeners();
  //     await _audioPlayer.play(UrlSource(audioUrl));
  //   } catch (e) {
  //     await stop();
  //     debugPrint('文本语音播放失败：$e');
  //   }
  // }

  // 在 AudioPlayerProvider 中添加/修改以下方法
  Future<void> toggleTextReadingState(String textId, String audioUrl) async {
    try {
      // 1. 停止所有正在播放的音频（包括普通音频和文本语音）
      await _stopAllPlayback();

      // 2. 如果点击的是同一个文本语音
      if (currentReadingTextId == textId) {
        if (isTextReading) {
          // 如果是正在播放状态，切换为暂停
          await _pauseReading();
        } else {
          // 如果是暂停状态，恢复播放
          await _resumeReading(audioUrl);
        }
      } else {
        // 3. 播放新的文本语音
        await _startNewReading(textId, audioUrl);
      }
    } catch (e) {
      debugPrint('文本语音切换失败: $e');
      await _handlePlaybackError();
    } finally {
      notifyListeners();
    }
  }

// 停止所有播放的私有方法
  Future<void> _stopAllPlayback() async {
    // 同时停止播放器和重置进度
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);

    // 重置所有播放状态
    _audioProgress = 0.0;
    currentAudioId = null;
    isAudioPlaying = false;

    // 只重置阅读状态如果当前有正在阅读的内容
    if (currentReadingTextId != null) {
      isTextReading = false;
    }
  }

// 暂停阅读的私有方法
  Future<void> _pauseReading() async {
    await _audioPlayer.pause();
    isTextReading = false;
    _audioProgress =
        (await _audioPlayer.getDuration())?.inMilliseconds as double ?? 0;
  }

// 恢复阅读的私有方法
  Future<void> _resumeReading(String audioUrl) async {
    // 检查是否需要重新加载源
    if (_audioPlayer.source == null) {
      await _audioPlayer.setSource(UrlSource(audioUrl));
    }
    await _audioPlayer.resume();
    isTextReading = true;

    // 添加进度监听
    _startProgressUpdates();
  }

// 开始新阅读的私有方法
  Future<void> _startNewReading(String textId, String audioUrl) async {
    // 完全重置播放器
    await _audioPlayer.dispose();
    _audioPlayer = AudioPlayer(); // 创建新实例避免状态残留

    // 设置新源
    await _audioPlayer.setSource(UrlSource(audioUrl));

    // 更新状态
    currentReadingTextId = textId;
    isTextReading = true;

    // 监听播放进度
    _startProgressUpdates();

    // 监听播放完成
    _audioPlayer.onPlayerComplete.listen((_) {
      _handlePlaybackComplete();
    });

    // 开始播放
    await _audioPlayer.resume();
  }

// 进度更新方法
  void _startProgressUpdates() {
    _audioPlayer.onPositionChanged.listen((Duration position) async {
      final duration = await _audioPlayer.getDuration() ?? Duration.zero;
      _audioProgress = duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;
      notifyListeners();
    });
  }

// 处理播放完成
  void _handlePlaybackComplete() {
    _audioProgress = 1.0;
    isTextReading = false;
    currentReadingTextId = null;
    notifyListeners();
  }

// 错误处理统一方法
  Future<void> _handlePlaybackError() async {
    await _audioPlayer.stop();
    _audioProgress = 0.0;
    isTextReading = false;
    currentReadingTextId = null;
    notifyListeners();
  }

  // 暂停音频播放
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    isAudioPlaying = false;
    notifyListeners();
  }

  // 暂停文本阅读
  Future<void> pauseReading() async {
    await _audioPlayer.pause();
    isTextReading = false;
    notifyListeners();
  }

  // 恢复播放音频
  Future<void> resumeAudioPlaying() async {
    await _audioPlayer.resume();
    isAudioPlaying = true;
    notifyListeners();
  }

  // 恢复阅读文本
  Future<void> resumeReading() async {
    await _audioPlayer.resume();
    isTextReading = true;
    notifyListeners();
  }

  // 设置音频文件
  Future<void> setAudioSource(String audioUrl, Duration? timeout) async {
    if (audioUrl.startsWith('http') || audioUrl.startsWith('https')) {
      _audioPlayer
          .setSource(UrlSource(audioUrl))
          .timeout(timeout ?? Duration(seconds: 0));
    } else {
      _audioPlayer
          .setSource(DeviceFileSource(audioUrl))
          .timeout(timeout ?? Duration(seconds: 0));
    }
    notifyListeners();
  }

  // 停止音频播放
  // Future<void> stop() async {
  //   await _audioPlayer.stop().then((_) => _audioPlayer.seek(Duration.zero));
  //   currentAudioId = null;
  //   currentReadingTextId = null;
  //   isAudioPlaying = false;
  //   isTextReading = false;
  //   notifyListeners();
  // }
  Future<void> stop() async {
    try {
      // 先暂停播放器
      await _audioPlayer.pause().timeout(const Duration(seconds: 5));

      // 异步执行 seek 操作并添加超时
      unawaited(_audioPlayer
          .seek(Duration.zero)
          .timeout(const Duration(seconds: 5))
          .catchError((e) => debugPrint('Seek error: $e')));

      // 完全停止播放器
      await _audioPlayer.stop().timeout(const Duration(seconds: 5));
    } on TimeoutException catch (_) {
      debugPrint('⚠️ Audio stop timeout');
      await _audioPlayer.dispose(); // 强制释放资源
    } finally {
      _currentAudioId = null;
      _currentReadingTextId = null;
      _isAudioPlaying = false;
      _isTextReading = false;
      notifyListeners();
    }
  }

  // 设置音频播放器播放状态
  void setAudioPlayingState(String audioId, bool playing) {
    currentReadingTextId = null;
    isTextReading = false;
    currentAudioId = playing ? audioId : null;
    isAudioPlaying = playing;
    notifyListeners();
  }

  // 设置文本阅读状态
  void setTextReadingState(String textId, bool reading) {
    currentAudioId = null;
    isAudioPlaying = false;
    currentReadingTextId = reading ? textId : null;
    isTextReading = reading;
    notifyListeners();
  }

  // 重置音频播放器状态
  void reset() {
    currentAudioId = null;
    currentReadingTextId = null;
    isAudioPlaying = false;
    isTextReading = false;
    notifyListeners();
  }
}
