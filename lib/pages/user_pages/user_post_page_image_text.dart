import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

// 图文投稿数据模型
class ImageTextPost {
  // 图片 URL
  final String imageUrl;

  // 点赞数
  final int likes;

  // 投稿标题
  final String title;

  // 图片高宽比
  final double aspectRatio;

  ImageTextPost(
      {required this.imageUrl,
      required this.likes,
      required this.title,
      required this.aspectRatio});
}

// 图文用户投稿页面
class UserImageTextPostPage extends StatelessWidget {
  final List<ImageTextPost> posts = [
    ImageTextPost(
      imageUrl: 'https://picsum.photos/300/400',
      likes: 234,
      title: '这是第一个投稿的标题内容可能会比较长需要截断处理',
      aspectRatio: 3 / 4,
    ),
    ImageTextPost(
      imageUrl: 'https://picsum.photos/300/500',
      likes: 156,
      title: '这是第一个投稿的标题内容可能会比较长需要截断处理',
      aspectRatio: 3 / 5,
    ),
    ImageTextPost(
      imageUrl: 'https://picsum.photos/300/400',
      likes: 234,
      title: '这是第一个投稿的标题内容可能会比较长需要截断处理',
      aspectRatio: 3 / 4,
    ),
    ImageTextPost(
      imageUrl: 'https://picsum.photos/300/600',
      likes: 156,
      title: '这是第一个投稿的标题内容可能会比较长需要截断处理',
      aspectRatio: 3 / 6,
    ),
    ImageTextPost(
      imageUrl: 'https://picsum.photos/300/300',
      likes: 234,
      title: '这是第一个投稿的标题内容可能会比较长需要截断处理',
      aspectRatio: 3 / 3,
    ),
    ImageTextPost(
      imageUrl: 'https://picsum.photos/300/500',
      likes: 156,
      title: '这是第一个投稿的标题内容可能会比较长需要截断处理',
      aspectRatio: 3 / 5,
    ),
  ];

  UserImageTextPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: WaterfallFlow.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            // 两列布局
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) =>
              ImageTextPostCard(post: posts[index]),
          itemCount: posts.length,
        ),
      ),
    );
  }
}

// 图文卡片投稿组件
class ImageTextPostCard extends StatelessWidget {
  final ImageTextPost post;

  const ImageTextPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 图片区域
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: AspectRatio(
              aspectRatio: post.aspectRatio,
              child: Stack(
                children: [
                  // 图片
                  Image.network(post.imageUrl, fit: BoxFit.cover),

                  // 底部渐变遮罩
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(8)),
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color.fromRGBO(0, 0, 0, 0.8),
                                  Colors.transparent,
                                ])),
                      ),
                    ),
                  ),

                  // 点赞数区域
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up_alt_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          post.likes.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 标题区域
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
