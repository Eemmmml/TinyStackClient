import 'package:flutter/material.dart';

import '../../entity/comment_item.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildCommentHeader(),
        ..._buildCommentList(),
      ],
    );
  }

  // 构建评论头
  Widget _buildCommentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '热门评论',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              // TODO: 实现选择评论排序方式，及排序相关的逻辑
            },
          ),
        ],
      ),
    );
  }

  // 构建评论列表
  List<Widget> _buildCommentList() {
    final List<Comment> commentsInfo = Comment.comments;

    return commentsInfo.map((item) => _buildCommentItem(item)).toList();
  }

  // 构建具体的评论列表内的元素
  Widget _buildCommentItem(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  // TODO: 从网络获取图片
                  // backgroundImage: NetworkImage(url),
                  backgroundImage: AssetImage(comment.avatar),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (comment.isAuthor)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'UP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          )
                      ],
                    ),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: comment.time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )),
                      const TextSpan(text: '  '),
                      TextSpan(
                          text: comment.ip,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ))
                    ])),
                  ],
                ),
              ],
            ),

            // 评论内容
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(comment.content),
            ),

            // 互动按钮
            Row(
              children: [
                _buildInteractionButton(Icons.thumb_up, comment.likeCount),
                const SizedBox(width: 20),
                _buildInteractionButton(Icons.thumb_down, comment.dislikeCount),
                const SizedBox(width: 20),
                const Icon(Icons.share, size: 18),
                const SizedBox(width: 20),
                const Icon(
                  Icons.chat_bubble_rounded,
                  size: 18,
                ),
              ],
            ),

            // 回复列表
            if (comment.replies.isNotEmpty)
              Column(
                children: [
                  const Divider(height: 24),
                  ...comment.replies.map((reply) => _buildReplyItem(reply)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem(Reply reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reply.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            reply.content,
            style: const TextStyle(
              fontSize: 14,
            ),
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

  // 构建可以交互的按钮
  Widget _buildInteractionButton(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        if (count >= 0)
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
