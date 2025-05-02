import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;

import '../../utils/time_format_utils.dart';

class VideoRecorderPage extends StatefulWidget {
  const VideoRecorderPage({super.key});

  @override
  State<VideoRecorderPage> createState() => _VideoRecorderPageState();

  // 静态方法：跳转到录制页面并返回结果
  static Future<Map<String, String?>> navigate(BuildContext context) async {
    // 检查摄像头权限
    // 请求相机权限
    final cameraStatus = await Permission.camera.request();
    // 请求麦克风权限
    final micStatus = await Permission.microphone.request();
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      debugPrint('照相机或麦克风权限获取失败');
      throw Exception('照相机或麦克风权限获取失败');
    }

    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoRecorderPage()),
    );
  }
}

class _VideoRecorderPageState extends State<VideoRecorderPage>
    with WidgetsBindingObserver {
  // 摄像机控制器
  CameraController? _cameraController;

  // 录制状态
  bool _isRecording = false;

  // 摄像机准备状态
  bool _isCameraReady = false;

  bool _isProcessing = false;

  // 视频路径
  String? _videoPath;

  // 摄像照片路径
  String? _photoPath;

  // 摄像机描述列表
  late List<CameraDescription> _cameras;

  // 录制按键计时器
  Timer? _holdTimer;

  // 录像计时器
  Timer? _recordTimer;

  // 录制时间
  int _recordDuration = 0;

  // 点击开始时间
  int _pressStartTime = 0;

  // 状态锁
  bool _isStopping = false;

  static const _stopTimeOut = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 初始化摄影机
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 销毁摄影机控制器
    _cameraController?.dispose();
    _holdTimer?.cancel();
    _recordTimer?.cancel();
    super.dispose();
  }

  // 监听应用生命周期，暂停释放摄像头
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        _initializeController(_cameraController!.description);
      }
    }
  }

  // 初始化摄像头
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('获取摄像头失败');
        _showErrorSnackBar('获取摄像头失败');
        throw Exception('获取摄像头失败');
      }

      await _initializeController(_cameras.first);
    } catch (e) {
      debugPrint('初始化摄像头失败: $e');
      _showErrorSnackBar('初始化摄像头失败');
      throw Exception('初始化摄像头失败: $e');
    }
  }

  Future<void> _initializeController(CameraDescription camera) async {
    // final preset = _getOptimalResolutionPreset();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.ultraHigh,
      // 启用音频
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);
      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      debugPrint('初始化摄像头控制器失败: $e');
      _showErrorSnackBar('初始化摄像头控制器失败');
      throw Exception('初始化摄像头控制器失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildGestureControlButton(),
        ],
      ),
    );
  }

  // 构建控制按钮
  Widget _buildGestureControlButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isRecording)
            Text(
              TimeFormatUtils.formatDuration(_recordDuration),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]),
            ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTapDown: (_) => _handlePressStart(),
              onLongPressEnd: (_) => _handlePressEnd(),
              onPanEnd: (_) => _handlePressEnd(),
              onTapUp: (_) => _handlePressEnd(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 70 : 60,
                height: _isRecording ? 70 : 60,
                decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red.withOpacity(0.8)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.camera_alt_outlined,
                  color: Colors.black,
                  size: _isRecording ? 36 : 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //摄像头预览界面
  Widget _buildCameraPreview() {
    if (!_isCameraReady || _cameraController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕约束动态调整尺寸
        final size = MediaQuery.of(context).size;
        final deviceRatio = size.aspectRatio;

        final previewSize = _cameraController!.value.previewSize;
        if (previewSize == null ||
            previewSize.width == 0 ||
            previewSize.height == 0) {
          return const Center(child: CircularProgressIndicator());
        }
        // 选择最大的缩放比例
        double scale = _cameraController!.value.aspectRatio / deviceRatio;

        return Center(
          child: Transform.scale(
            scale: scale,
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: Center(child: CameraPreview(_cameraController!)),
            ),
          ),
        );
      },
    );
  }

  void _handlePressStart() async {
    if (!_isCameraReady || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _pressStartTime = DateTime.now().millisecondsSinceEpoch;
    });

    _holdTimer = Timer(const Duration(seconds: 1), () {
      if (_isProcessing) {
        _startVideoRecording();
        _startRecordTimer();
      }
    });
  }

  void _handlePressEnd() async {
    if (!_isProcessing) return;

    _holdTimer?.cancel();
    final duration = DateTime.now().millisecondsSinceEpoch - _pressStartTime;
    final isShortPress = duration < 1000;

    try {
      if (isShortPress) {
        await _takePhoto();
      } else if (_isRecording) {
        await _stopVideoRecording();
      }
    } catch (e) {
      debugPrint('操作失败: $e');
      _showErrorSnackBar('操作失败');
      throw Exception('操作失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isProcessing = false;
          _recordDuration = 0;
        });
      }
    }
  }

  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordDuration = 0;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording || !mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _recordDuration = timer.tick;
      });
    });
  }

  // 拍照
  Future<void> _takePhoto() async {
    debugPrint('开始拍照');
    try {
      final XFile photo = await _cameraController!.takePicture();
      final Directory appDir = await getTemporaryDirectory();
      _photoPath =
          '${appDir.path}/tinystack_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await photo.saveTo(_photoPath!);

      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _recordDuration = 0;
      });

      debugPrint('拍照成功');
      if (mounted) {
        Navigator.pop(context, {
          'photoPath': _photoPath,
          'videoPath': null,
          'thumbnailPath': null,
        });
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
      _showErrorSnackBar('拍照失败');
      throw Exception('拍照失败: $e');
    }
  }

  // 长按开始录制
  void _onLongPressStart() {
    if (!_isCameraReady || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _startVideoRecording();

    // 更新录制时间（每秒更新一次）
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration = timer.tick;
      });
    });
  }

  // 松手或滑动取消停止录制
  void _onLongPressEnd(LongPressEndDetails details) {
    _holdTimer?.cancel();
    if (_isRecording) {
      _stopVideoRecording();
    }
    setState(() {
      _isProcessing = false;
      _recordDuration = 0;
    });
  }

  // 滑动取消录制，如手指滑出按钮区域
  void _onPanEnd(DragEndDetails details) {
    if (_isRecording) {
      _cancelRecording();
    }
    setState(() {
      _isProcessing = false;
      _recordDuration = 0;
    });
  }

  Future<void> _startVideoRecording() async {
    debugPrint('开始录像');
    try {
      final Directory appDir = await getTemporaryDirectory();
      final String videoPath =
          '${appDir.path}/tinystack_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _cameraController!.startVideoRecording();
      setState(() {
        _isProcessing = true;
        _isRecording = true;
      });
      _videoPath = videoPath;
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      debugPrint('视频录制启动失败: $e');
      _showErrorSnackBar('视频录制启动失败');
      throw Exception('视频录制启动失败: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_isStopping || !_isRecording) return;
    _isStopping = true;
    debugPrint('开始停止录像');

    try {
      setState(() {
        _isProcessing = false;
        _isRecording = false;
      });
      if (!_cameraController!.value.isRecordingVideo) return;

      final XFile videoFile = await _cameraController!
          .stopVideoRecording()
          .timeout(_stopTimeOut, onTimeout: () {
        debugPrint('停止录制超时');
        throw Exception('停止录制超时');
      });
      await videoFile.saveTo(_videoPath!);
      _recordTimer?.cancel();

      if (mounted) {
        _returnVideoWithThumbnail();
      }
      debugPrint('录像结束');
    } catch (e) {
      debugPrint('视频录制停止失败: $e');
      _showErrorSnackBar('视频录制停止失败');
      throw Exception('视频录制停止失败: $e');
    } finally {
      _isStopping = false;
      _recordTimer?.cancel();
      if (mounted) {
        setState(() {
          _recordDuration = 0;
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    try {
      if (!_cameraController!.value.isRecordingVideo) return;

      await _cameraController!.stopVideoRecording();
      setState(() {
        _isProcessing = false;
        _isRecording = false;
        _recordDuration = 0;
      });

      // 后续进行视频数据上传时，上传后进行本地数据清理
      // if (_videoPath != null) {
      //   final file = File(_videoPath!);
      //   if (await file.exists()) await file.delete();
      // }
    } catch (e) {
      debugPrint('视频录制取消失败: $e');
      _showErrorSnackBar('视频录制取消失败');
      throw Exception('视频录制取消失败: $e');
    }
  }

  Future<void> _returnVideoWithThumbnail() async {
    final thumbnailPath = await video_thumbnail.VideoThumbnail.thumbnailFile(
      video: _videoPath!,
      timeMs: 0,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: video_thumbnail.ImageFormat.JPEG,
      quality: 100,
    );

    if (mounted) {
      Navigator.pop(context, {
        'photoPath': null,
        'videoPath': _videoPath,
        'thumbnailPath': thumbnailPath,
      });
    }
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
