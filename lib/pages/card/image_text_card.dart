import 'package:flutter/material.dart';

import '../../entity/image_text_item.dart';

class ImageTextCard extends StatelessWidget {
  final ImageTextItem imageTextItem;

  const ImageTextCard({super.key, required this.imageTextItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              imageTextItem.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 图片
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageTextItem.imageUrl),
                fit: BoxFit.cover,
              )
            ),
          ),


          // 内容概览
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              imageTextItem.content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),


          // 底部数据
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetaItem(Icons.category, imageTextItem.category),
                _buildMetaItem(Icons.visibility_outlined, imageTextItem.viewCount),
                _buildMetaItem(Icons.comment, imageTextItem.commentCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 原数据构建方法
  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
