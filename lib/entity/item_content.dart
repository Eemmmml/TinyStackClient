import 'dart:async';

// 内容数据模型
class ContentItem {
  final String title;
  final String author;
  final String imageUrl;

  ContentItem(
      {required this.title, required this.author, required this.imageUrl});
}

// 模拟数据源
// TODO: 后续修改为实际的网络数据源
class MockData {
  static Future<List<ContentItem>> fetchData(int page, int pageSize) async {
    // 模拟网络延迟
    await Future.delayed(Duration(seconds: 1));

    // 生成模拟数据
    return List.generate(
        pageSize,
        (index) => ContentItem(
              title: '第 $page 页内容 ${index + 1}',
              author: '作者 ${(page - 1) * pageSize + index + 1}',
              imageUrl: 'assets/user_info/user_avatar1.jpg',
            ));
  }
}
