import 'package:flutter/material.dart';

import '../../entity/comment_item.dart';
import 'reply_detail_page.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  // 可变的评论列表
  late List<Comment> _comments;

  // 最多可见的回复数
  static const _maxVisibleReplies = 2;

  // 添加折叠状态管理
  final Map<int, bool> _expandedComments = {};

  @override
  void initState() {
    super.initState();
    // 模拟初始化数据
    _comments = Comment.comments;
  }

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
    return _comments.map((item) => _buildCommentItem(item)).toList();
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
                // 点赞
                _buildInteractionButton(comment, true),
                const SizedBox(width: 20),
                // 差评
                _buildInteractionButton(comment, false),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.share, size: 18),
                  onPressed: () => _handleShare(comment),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  onPressed: () => _handleReply(comment),
                ),
              ],
            ),

            // 回复列表
            if (comment.replies.isNotEmpty) _buildReplySection(comment),
            //     if (comment.replies.isNotEmpty)
            //       Column(
            //         children: [
            //           const Divider(height: 24),
            //           ...comment.replies.map((reply) => _buildReplyItem(reply)),
            //         ],
            //       ),
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
  Widget _buildInteractionButton(Comment comment, bool isLike) {
    final icon = isLike ? Icons.thumb_up : Icons.thumb_down;
    final count = isLike ? comment.likeCount : comment.dislikeCount;
    final isActive = isLike ? comment.isLiked : comment.isDisliked;

    return GestureDetector(
      onTap: () => _handleVote(comment, isLike),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? Colors.pinkAccent : Colors.grey,
          ),
          const SizedBox(width: 4),
          if (count >= 0)
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.pinkAccent : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // 点赞和差评逻辑处理
  void _handleVote(Comment comment, bool isLike) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);

      if (index == -1) {
        return;
      }

      final newComment = _comments[index].copyWith();

      // 点击了点赞按钮
      if (isLike) {
        if (newComment.isLiked) {
          newComment.likeCount--;
          newComment.isLiked = false;
        } else {
          newComment.likeCount++;
          newComment.isLiked = true;
          newComment.dislikeCount = newComment.isDisliked
              ? (newComment.dislikeCount - 1 < 0
                  ? 0
                  : newComment.dislikeCount - 1)
              : newComment.dislikeCount;
          newComment.isDisliked = false;
        }
        // 点击了差评按钮
      } else {
        if (newComment.isDisliked) {
          newComment.dislikeCount--;
          newComment.isDisliked = false;
        } else {
          newComment.dislikeCount++;
          newComment.isDisliked = true;
          newComment.likeCount = newComment.isLiked
              ? (newComment.likeCount - 1 < 0 ? 0 : newComment.likeCount - 1)
              : newComment.likeCount;
          newComment.isLiked = false;
        }
      }

      _comments[index] = newComment;

      // TODO: 调用 API 同步更新后台服务端的数据
    });
  }

  // 处理分享逻辑
  void _handleShare(Comment comment) {
    // TODO: 实现分享逻辑
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('分享评论：${comment.content.substring(0, 10)}...'),
    ));
  }

  // 处理评论逻辑
  void _handleReply(Comment comment) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: '回复@${comment.username}',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 提交回复
                      Navigator.pop(context);
                    },
                    child: const Text('发送回复'),
                  )
                ],
              ),
            ));
  }

  // 构建评论回复部分
  Widget _buildReplySection(Comment comment) {
    final totalReplies = comment.replies.length;
    final visibleReplies = _expandedComments[comment.id] ?? false
        ? comment.replies
        : comment.replies.take(_maxVisibleReplies).toList();

    return Column(
      children: [
        const Divider(height: 24),
        ...visibleReplies.map((reply) => _buildReplyItem(reply)),
        if (totalReplies > _maxVisibleReplies &&
            !(_expandedComments[comment.id] ?? false))
          _buildShowMoreButton(comment, totalReplies),
      ],
    );
  }

  // 构建显示更多回复的按钮
  Widget _buildShowMoreButton(Comment comment, int total) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () => _handleShowMoreReplies(comment),
        child: Text.rich(TextSpan(
          children: [
            const TextSpan(text: '共 '),
            TextSpan(
              text: '${total - _maxVisibleReplies}',
              style: const TextStyle(color: Colors.blue),
            ),
            const TextSpan(text: ' 条回复'),
          ],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        )),
      ),
    );
  }

  // 处理显示更多的回复
  void _handleShowMoreReplies(Comment comment) {
    // 跳转回复详情页面
    // TODO: 构建实际的回复详情页面
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReplyDetailPage(
                comment: comment, onBack: () => setState(() {}))));
  }
}
