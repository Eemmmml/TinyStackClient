import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/pojo/content_pojo/content_preview_get_page_pojo.dart';

part 'content_preview_item.g.dart';

// 内容数据模型
@JsonSerializable()
class ContentPreviewItem {
  final int? id;
  final int? authorID;
  final String title;
  final String author;
  final String imageUrl;

  ContentPreviewItem(
      {this.id,
      this.authorID,
      required this.title,
      required this.author,
      required this.imageUrl});

  factory ContentPreviewItem.fromJson(Map<String, dynamic> json) => _$ContentPreviewItemFromJson(json);

  Map<String, dynamic> toJson() => _$ContentPreviewItemToJson(this);
}

// 模拟数据源
// TODO: 后续修改为实际的网络数据源
class MockData {
  static Future<List<ContentPreviewItem>> fetchData(
      int page, int pageSize) async {
    // 模拟网络延迟
    await Future.delayed(Duration(seconds: 1));

    // 生成模拟数据
    return List.generate(
        pageSize,
        (index) => ContentPreviewItem(
              title: '第 $page 页内容 ${index + 1}',
              author: '作者 ${(page - 1) * pageSize + index + 1}',
              imageUrl: 'assets/user_info/user_avatar1.jpg',
            ));
  }
}

class ContentPreviewDataLoader {
  static final dio = Dio();
  static final logger = Logger();

  static Future<List<ContentPreviewItem>> fetchData(int page, int pageSize) async {
    final url = '${DioConfig.severUrl}/content';
    final response = await dio.get(url, queryParameters: {
      'pageNum': page,
      'pageSize': pageSize,
    });

    if (response.statusCode == 200) {
      final result = ContentPreviewGetPagePojo.fromJson(response.data);
      if (result.code == 1) {
        logger.d('内容预览数据加载成功');
        return result.data;
      } else {
        logger.d('内容预览数据加载失败: msg: ${result.msg}');
        return [];
      }
    } else {
      logger.d('内容预览数据加载失败');
      return [];
    }
  }
}
