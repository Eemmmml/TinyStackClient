import 'package:flutter/material.dart';
import 'package:tinystack/entity/comment_item.dart';

// 回复详情页面
class ReplyDetailPage extends StatelessWidget {
  final Comment comment;
  final VoidCallback onBack;

  const ReplyDetailPage(
      {super.key, required this.comment, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('共 ${comment.replies.length} 条回复'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            onBack();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          // 原评论
          _buildOriginalComment(comment),
          Padding(padding: const EdgeInsets.all(12), child: Divider(height: 5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '全部回复',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(height: 2),
          ),
          // 全部评论
          ...comment.replies.map((reply) => _buildReplyItem(reply)),
        ],
      ),
    );
  }

  // 构建原初评论的部分
  Widget _buildOriginalComment(Comment comment) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                // TODO: 实现从网络加载图片
                // backgroundImage: NetworkImage(url),
                backgroundImage: AssetImage(comment.avatar),
              ),
              const SizedBox(width: 8),
              Text(
                comment.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(comment.content),
          ),
          Text(
            '${comment.time} · ${comment.ip}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 构建实际的回复元素
  Widget _buildReplyItem(Reply reply) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                // TODO: 实现从网络加载图片
                // backgroundImage: NetworkImage(url),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 8),
              Text(
                reply.username,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              if (reply.tag != null)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTagColor(reply.tag!),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    reply.tag!,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Text(reply.content),
          ),
        ],
      ),
    );
  }

  // 获取 TAG 的颜色
  Color _getTagColor(String tag) {
    switch (tag) {
      case 'UP':
        return Colors.red;
      case '铁粉':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
