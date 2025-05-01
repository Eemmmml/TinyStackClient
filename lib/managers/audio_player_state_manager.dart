import 'package:flutter/foundation.dart';

class AudioPlayerStateProvider extends ChangeNotifier {
  String? _currentAudioId;
  bool _isPlaying = false;

  // 获取当前播放音频的 ID
  String? get currentAudioId => _currentAudioId;

  // 获取音频播放器的工作状态
  bool get isPlaying => _isPlaying;

  // 设置音频播放器播放状态
  void setPlayingState(String audioId, bool playing) {
    _currentAudioId = playing ? audioId : null;
    _isPlaying = playing;
    notifyListeners();
  }

  // 重置音频播放器状态
  void reset() {
    _currentAudioId = null;
    _isPlaying = false;
    notifyListeners();
  }
}