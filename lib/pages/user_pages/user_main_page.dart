import 'package:flutter/material.dart';

import '../../entity/image_text_item.dart';
import '../../entity/video_collection.dart';
import '../card/image_text_card.dart';

class UserMainPage extends StatelessWidget {
  final List<VideoCollection> dummyCollections =
      VideoCollection.getDummyCollections();

  UserMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 视频区块
          _buildVideoSection(),
          const SizedBox(height: 24),
          // 图文区块
          _buildImageTextSection(),
          const SizedBox(height: 24),
          // 合集区块
          _buildCollectionSection()
        ],
      ),
    );
  }

  // 视频区块构建
  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区块头部
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SectionHeader(
              title: '视频', count: 12, onTap: () => _handleSeeMore('视频')),
        ),

        GridView.count(
          padding: const EdgeInsets.only(top: 15),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: List.generate(
              4,
              (index) =>
                  VideoCollectionCard(collection: dummyCollections[index])),
        ),
        // 网格布局
      ],
    );
  }

  // 图文区块构建
  Widget _buildImageTextSection() {
    final posts = ImageTextItem.getDummyPosts();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: '图文', count: 8, onTap: () => _handleSeeMore('图文')),
        const SizedBox(height: 8),
        ...posts.map((post) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ImageTextCard(imageTextItem: post),
            )),
      ],
    );
  }

  // 合集区块构建
  Widget _buildCollectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区块头部
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SectionHeader(
              title: '视频', count: 12, onTap: () => _handleSeeMore('视频')),
        ),

        GridView.count(
          padding: const EdgeInsets.only(top: 15),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: List.generate(
              2,
              (index) =>
                  VideoCollectionCard(collection: dummyCollections[index])),
        ),
        // 网格布局
      ],
    );
  }

  void _handleSeeMore(String section) {
    // TODO: 处理查看更多点击时间
  }
}

// 区块头部通用组件
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const SectionHeader(
      {super.key,
      required this.title,
      required this.count,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              children: [
                TextSpan(text: '$title  '),
                TextSpan(
                  text: '$count',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Text('查看更多',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 视频合集卡片组件
class VideoCollectionCard extends StatelessWidget {
  final VideoCollection collection;

  const VideoCollectionCard({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(
          color: Color.fromRGBO(128, 128, 128, 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片 + 渐变遮罩
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.network(
                  collection.coverUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // 渐变遮罩
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // 统计数据
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatsIcon(
                        icon: Icons.play_arrow,
                        value: collection.playCount,
                      ),
                      _buildStatsIcon(
                        icon: Icons.comment,
                        value: collection.commentCount,
                      ),
                      _buildStatsIcon(
                        icon: Icons.video_library,
                        value: collection.videoCount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 合集名称

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Text(
                collection.title,
                style: TextStyle(fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建合集数据行
  Widget _buildStatsIcon({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
