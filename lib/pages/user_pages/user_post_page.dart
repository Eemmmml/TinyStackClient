import 'package:flutter/material.dart';

import '../card/video_card.dart';
import 'user_post_page_image_text.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({super.key});

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  // 当前选中的分类的索引
  int _selectedCategoryIndex = 0;

  // 用户投稿分类
  final List<String> _categories = ['全部', '图文', '生活', '旅行', '美食', '工作', '其他'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildCategoryScroll(),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedCategoryIndex == 1
                ? UserImageTextPostPage()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: 10,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[300],
                        indent: 16,
                        endIndent: 16,
                      ),
                    ),
                    itemBuilder: (context, index) => VideoCard(
                      title:
                          '这时一个视频标题，很长很很很长很长很长很长很长很长很长很长很长很长长很长很长很长很长很长很长很长很长很长长很长很长很长很长很长很长很长很长很长',
                      duration: Duration(minutes: 5, seconds: 30),
                      publishTime: DateTime.now().subtract(Duration(hours: 2)),
                      views: 150,
                      comments: 45,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 构建顶部滚动胶囊列表
  Widget _buildCategoryScroll() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: _selectedCategoryIndex == index
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
