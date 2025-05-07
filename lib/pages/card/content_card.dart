import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;

  const ContentCard(
      {super.key,
      required this.title,
      required this.author,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              // TODO: 改为从网络获取图片资源
              // child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
              // child: Image.asset(imageUrl,
              //     fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        author,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: 实现更多按钮点击逻辑
                        print('点击图片');
                      },
                      child: Icon(Icons.more_vert, size: 20),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
