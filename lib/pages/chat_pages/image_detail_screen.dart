import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetailScreen extends StatefulWidget {
  final String imageUrl;

  const ImageDetailScreen({super.key, required this.imageUrl});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 允许所有方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // 恢复默认方向
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: OrientationBuilder(builder: (context, orientation) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Stack(
              children: [
                _buildAdaptivePhotoView(orientation),
                // 右下角操作按钮
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Row(
                    children: [
                      _buildActionButton(
                          icon: Icons.download_outlined,
                          onPressed: _handleDownload),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.share,
                        onPressed: _handleShare,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }));
  }

  Widget _buildAdaptivePhotoView(Orientation orientation) {
    return Positioned.fill(
      child: PhotoView(
        imageProvider: NetworkImage(widget.imageUrl),
        heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrl),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        enableRotation: false,
        basePosition: orientation == Orientation.portrait
            ? Alignment.center
            : Alignment.center,
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 4,
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: Color.fromRGBO(255, 255, 255, 0.2),
      shape: const CircleBorder(),
      // 通过InkWell包裹确保点击区域和视觉区域一致
      child: InkWell(
        borderRadius: BorderRadius.circular(100), // 确保圆形
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6), // 控制图标与边框的间距（核心调整点）
          child: Icon(icon, color: Colors.white, size: 20), // 图标尺寸与内边距匹配
        ),
      ),
    );
  }

  // 处理下载事件
  Future<void> _handleDownload() async {
    debugPrint('点击下载按钮');
    // 检查 widget 是否已挂载
    if (!mounted) {
      debugPrint('返回1');
      return;
    }
    try {
      // 检测设备存储权限
      final PermissionStatus status;
      if (Platform.isAndroid) {
        if (await Permission.sensors.isPermanentlyDenied) {
          openAppSettings();
          return;
        }
        if (await Permission.photos.isDenied) {
          status = await Permission.photos.request();
        } else {
          status = PermissionStatus.granted;
        }
      } else {
        status = await Permission.photosAddOnly.request();
      }

      if (!status.isGranted) {
        debugPrint('返回3');
        _showToast('存储权限被拒绝');
        return;
      }

      // 添加调试日志
      debugPrint('权限已获取：$status');

      // 显示加载指示器
      if (!mounted) {
        debugPrint('返回2');
        return;
      }
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.clearSnackBars();
      scaffold.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 12),
              Text('正在下载图片....'),
            ],
          ),
          duration: Duration(minutes: 1),
        ),
      );

      // 下载图片文件
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) {
        throw Exception('下载失败：${response.statusCode}');
      }
      final bytes = response.bodyBytes;

      // 创建临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'tinystack_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // 保存到相册
      final result = await ImageGallerySaverPlus.saveFile(file.path);
      final bool success = result['isSuccess'] as bool;
      if (success != null && success) {
        _showToast('图片已保存到相册');
      } else {
        _showToast("保存失败");
      }
    } catch (e) {
      _showToast('下载失败：${e.toString()}');
    } finally {
      // 隐藏加载指示器
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
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

  // 处理分享事件
  void _handleShare() {
    // TODO: 实现分享逻辑
  }
}
