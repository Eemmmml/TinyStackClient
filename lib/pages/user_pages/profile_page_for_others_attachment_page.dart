import 'dart:async';

import 'package:flutter/material.dart';

import '../../entity/user_profile_attachment.dart';

class DynamicList extends StatelessWidget {
  final List<Dynamic> dynamics;

  const DynamicList({super.key, required this.dynamics});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dynamics.length,
      itemBuilder: (context, index) => DynamicItem(dynamic: dynamics[index]),
    );
  }
}

class DynamicItem extends StatefulWidget {
  final Dynamic dynamic;

  const DynamicItem({super.key, required this.dynamic});

  @override
  State<DynamicItem> createState() => _DynamicItemState();
}

class _DynamicItemState extends State<DynamicItem> {
  // 内容展开状态
  bool _isContentExpanded = false;
  bool _showExpandButton = false;
  late TextPainter _textPainter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureText());
  }

  // 计算文本
  void _measureText() {
    final textStyle = const TextStyle(
      fontSize: 15,
      color: Colors.black,
    );

    // // 创建带按钮占位的文本测量
    // final fullContent = _buildRichText(true);
    // final textSpan = fullContent.text;

    _textPainter = TextPainter(
      text: TextSpan(text: widget.dynamic.content, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 4,
      ellipsis: '...',
    )..layout(maxWidth: _availableContentWidth);

    setState(() {
      // 同时满足系统省略和实际高度判断
      _showExpandButton = _textPainter.didExceedMaxLines;
    });
  }

  // 左右边距总和
  double get _availableContentWidth => MediaQuery.of(context).size.width - 20;

  RichText _buildRichText() {
    final textStyle = const TextStyle(
      fontSize: 15,
      color: Colors.black,
    );

    final children = <InlineSpan>[
      TextSpan(text: _getDisplayText()),
    ];

    if (_showExpandButton && !_isContentExpanded) {
      children.add(WidgetSpan(
          child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: GestureDetector(
          onTap: _toggleContentExpand,
          child: Text(
            '...全文',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )));
    }

    return RichText(
      maxLines: _isContentExpanded ? null : 4,
      overflow: _isContentExpanded ? TextOverflow.clip : TextOverflow.visible,
      text: TextSpan(
        style: textStyle,
        children: children,
      ),
    );
  }

  String _getDisplayText() {
    if (_isContentExpanded) return widget.dynamic.content;

    // 手动截断文本，比系统少3个字符用户放置按钮
    final text = widget.dynamic.content;
    final maxLength = _calculateMaxTextLength();
    return text.length > maxLength ? text.substring(0, maxLength) : text;
  }

  int _calculateMaxTextLength() {
    final text = widget.dynamic.content;
    final textStyle = const TextStyle(fontSize: 15);

    // 计算可用空间能显示的最大字符数
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 4,
    )..layout(maxWidth: _availableContentWidth - 40); // 预留按钮控件

    var offset = textPainter
        .getPositionForOffset(Offset(textPainter.width, textPainter.height))
        .offset;

    return offset - 3;
  }

  // 切换内容展开状态
  void _toggleContentExpand() {
    setState(() {
      _isContentExpanded = !_isContentExpanded;
    });
  }

  // TODO: 将按钮点击行为修改为跳转详细页面
  void _jumpToDetailPage() {}

  // 构建动态内容部分
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: _showExpandButton ? _toggleContentExpand : null,
        child: _buildRichText(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildContent(),
          const SizedBox(height: 8),
          _buildAttachments(),
          const SizedBox(height: 12),
          _buildInteractionBar(),
        ],
      ),
    );
  }

  // 构建头部
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          // TODO: 通过网络获取图片
          backgroundImage: AssetImage(widget.dynamic.user.avatarUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.dynamic.user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTime(widget.dynamic.publishTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: 实现点击逻辑
          },
        ),
      ],
    );
  }

  // // 构建动态内容部分
  Widget _buildAttachments() {
    if (widget.dynamic.attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      children: widget.dynamic.attachments.map((attachment) {
        switch (attachment.type) {
          case AttachmentType.image:
            return _buildImageGrid(attachment.urls!);
          case AttachmentType.video:
            return _buildVideoPreview(attachment.urls!.first);
          case AttachmentType.quote:
            return _buildQuoteDynamic(attachment.quotedDynamic!);
        }
      }).toList(),
    );
  }

  // 创建图片元素
  Widget _buildImageItem(String url) {
    return GestureDetector(
      onTap: () {
        // TODO: 实现图片点击逻辑
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            // 加载状态处理
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // 错误状态处理
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  // 构建单张图片（自适应比例）
  Widget _buildSingleImage(String url) {
    return FutureBuilder<Size>(
      future: _getImageSize(url),
      builder: (context, snapshot) {
        final double ratio = snapshot.hasData
            ? snapshot.data!.width / snapshot.data!.height
            : 1; //默认使用正方形

        return AspectRatio(
          aspectRatio: ratio,
          child: _buildImageItem(url),
        );
      },
    );
  }

  // 当动态附件为图片是创建网格页面
  Widget _buildImageGrid(List<String> urls) {
    final itemCount = urls.length > 9 ? 9 : urls.length;
    final crossAxisCount = urls.length == 1 ? 1 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: urls.length == 1 ? 1 : 1, // 基础比例，实际由图片决定
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (urls.length > 9 && index == 8) {
          return _buildOverflowThumbnail(urls.length - 9, urls[index]);
        }
        return urls.length == 1
            ? _buildSingleImage(urls[index])
            : _buildGridImage(urls[index]);
      },
    );
  }

  // 构建网格图片（固定正方形）
  Widget _buildGridImage(String url) {
    return AspectRatio(
      aspectRatio: 1,
      child: _buildImageItem(url),
    );
  }

  // 构建超过显示数量的缩略图
  Widget _buildOverflowThumbnail(int remainingCount, String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 实际图片内容
        _buildImageItem(imageUrl),

        // 遮罩层
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Colors.transparent,
                Color.fromRGBO(0, 0, 0, 0.7),
              ])),
        ),

        // 数量提示
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 获取图片尺寸
  Future<Size> _getImageSize(String imageUrl) {
    final completer = Completer<Size>();
    // TODO: 修改代码为从网络获取图片
    final image = Image.asset(imageUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    return completer.future;
  }

  // // 当动态附件为视频时，创建视频预览页面
  // Widget _buildVideoPreview(String videoUrl) {
  //   return GestureDetector(
  //     onTap: () {
  //       // TODO: 处理视频点击事件
  //     },
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         // TODO: 改为从网络获取图片资源
  //         Image.asset(videoUrl, fit: BoxFit.cover),
  //         const Icon(Icons.play_circle_filled, size: 48, color: Colors.white),
  //       ],
  //     ),
  //   );
  // }

  // 当动态附件为视频时，创建视频预览页面
  Widget _buildVideoPreview(String videoUrl) {
    return GestureDetector(
      onTap: () {
        // TODO: 处理视频点击事件
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TODO: 改为从网络获取图片资源
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(videoUrl, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: const Icon(Icons.play_circle_outline,
                size: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 当动态附件为动态引用时，创建动态页面
  Widget _buildQuoteDynamic(Dynamic quotedDynamic) {
    return GestureDetector(
      onTap: () {
        // TODO: 处理动态点击事件
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: DynamicItemForQuote(dynamic: quotedDynamic),
      ),
    );
  }

  // // 构建可以交互的 ICON 列表
  // Widget _buildInteractionBar() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     children: [
  //       _buildInteractionButton(Icons.share, widget.dynamic.shareCount),
  //       _buildInteractionButton(Icons.comment, widget.dynamic.commentCount),
  //       _buildInteractionButton(Icons.thumb_up, widget.dynamic.likeCount),
  //     ],
  //   );
  // }
  //

  // 构建可以交互的 ICON 列表
  Widget _buildInteractionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
            Text(widget.dynamic.shareCount.toString()),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {},
            ),
            Text(widget.dynamic.shareCount.toString()),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.thumb_up,
                  color:
                      widget.dynamic.isLiked ? Colors.pink : Colors.grey[800]),
              onPressed: () {
                setState(() {
                  if (widget.dynamic.isLiked) {
                    widget.dynamic.likeCount--;
                  } else {
                    widget.dynamic.likeCount++;
                  }
                  widget.dynamic.isLiked = !widget.dynamic.isLiked;
                });
              },
            ),
            Text(widget.dynamic.shareCount.toString()),
          ],
        ),
      ],
    );
  }

  // // 构建交互按钮组件
  // Widget _buildInteractionButton(IconData icon, int count) {
  //   return Row(
  //     children: [
  //       IconButton(
  //         icon: Icon(icon),
  //         onPressed: () {
  //           // TODO: 添加按钮点击事件
  //         },
  //       ),
  //       Text(count.toString()),
  //     ],
  //   );
  // }

  // // 构建交互按钮组件
  // Widget _buildInteractionButton(icon, int count) {
  //   return Row(
  //     children: [
  //       IconButton(
  //         icon: Icon(icon),
  //         onPressed: () {
  //           // TODO: 添加按钮点击事件
  //         },
  //       ),
  //       Text(count.toString()),
  //     ],
  //   );
  // }

  // 格式化时间
  String _formatTime(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inDays > 0) return '${duration.inDays}天前';
    if (duration.inHours > 0) return '${duration.inHours}小时前';
    if (duration.inMinutes > 0) return '${duration.inMinutes}分钟前';
    return '刚刚';
  }
}

// 用来引用的动态实体
class DynamicItemForQuote extends StatefulWidget {
  final Dynamic dynamic;

  const DynamicItemForQuote({super.key, required this.dynamic});

  @override
  State<DynamicItemForQuote> createState() => _DynamicItemForQuoteState();
}

class _DynamicItemForQuoteState extends State<DynamicItemForQuote> {
  // 内容展开状态
  bool _isContentExpanded = false;
  bool _showExpandButton = false;
  late TextPainter _textPainter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureText());
  }

  // 计算文本
  void _measureText() {
    final textStyle = const TextStyle(
      fontSize: 15,
      color: Colors.black,
    );

    // // 创建带按钮占位的文本测量
    // final fullContent = _buildRichText(true);
    // final textSpan = fullContent.text;

    _textPainter = TextPainter(
      text: TextSpan(text: widget.dynamic.content, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 4,
      ellipsis: '...',
    )..layout(maxWidth: _availableContentWidth);

    setState(() {
      // 同时满足系统省略和实际高度判断
      _showExpandButton = _textPainter.didExceedMaxLines;
    });
  }

  // 左右边距总和
  double get _availableContentWidth => MediaQuery.of(context).size.width - 20;

  RichText _buildRichText() {
    final textStyle = const TextStyle(
      fontSize: 15,
      color: Colors.black,
    );

    final children = <InlineSpan>[
      TextSpan(text: _getDisplayText()),
    ];

    if (_showExpandButton && !_isContentExpanded) {
      children.add(WidgetSpan(
          child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: GestureDetector(
          onTap: _toggleContentExpand,
          child: Text(
            '...全文',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )));
    }

    return RichText(
      maxLines: _isContentExpanded ? null : 4,
      overflow: _isContentExpanded ? TextOverflow.clip : TextOverflow.visible,
      text: TextSpan(
        style: textStyle,
        children: children,
      ),
    );
  }

  String _getDisplayText() {
    if (_isContentExpanded) return widget.dynamic.content;

    // 手动截断文本，比系统少3个字符用户放置按钮
    final text = widget.dynamic.content;
    final maxLength = _calculateMaxTextLength();
    return text.length > maxLength ? text.substring(0, maxLength) : text;
  }

  int _calculateMaxTextLength() {
    final text = widget.dynamic.content;
    final textStyle = const TextStyle(fontSize: 15);

    // 计算可用空间能显示的最大字符数
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 4,
    )..layout(maxWidth: _availableContentWidth - 40); // 预留按钮控件

    var offset = textPainter
        .getPositionForOffset(Offset(textPainter.width, textPainter.height))
        .offset;

    return offset - 3;
  }

  // 切换内容展开状态
  void _toggleContentExpand() {
    setState(() {
      _isContentExpanded = !_isContentExpanded;
    });
  }

  // TODO: 将按钮点击行为修改为跳转详细页面
  void _jumpToDetailPage() {}

  // 构建动态内容部分
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: _showExpandButton ? _toggleContentExpand : null,
        child: _buildRichText(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildContent(),
          const SizedBox(height: 8),
          _buildAttachments(),
        ],
      ),
    );
  }

  // 构建头部
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          // TODO: 通过网络获取图片
          backgroundImage: AssetImage(widget.dynamic.user.avatarUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.dynamic.user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTime(widget.dynamic.publishTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  // // 构建动态内容部分
  Widget _buildAttachments() {
    if (widget.dynamic.attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      children: widget.dynamic.attachments.map((attachment) {
        switch (attachment.type) {
          case AttachmentType.image:
            return _buildImageGrid(attachment.urls!);
          case AttachmentType.video:
            return _buildVideoPreview(attachment.urls!.first);
          case AttachmentType.quote:
            return _buildQuoteDynamic(attachment.quotedDynamic!);
        }
      }).toList(),
    );
  }

  // 创建图片元素
  Widget _buildImageItem(String url) {
    return GestureDetector(
      onTap: () {
        // TODO: 实现图片点击逻辑
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            // 加载状态处理
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // 错误状态处理
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  // 构建单张图片（自适应比例）
  Widget _buildSingleImage(String url) {
    return FutureBuilder<Size>(
      future: _getImageSize(url),
      builder: (context, snapshot) {
        final double ratio = snapshot.hasData
            ? snapshot.data!.width / snapshot.data!.height
            : 1; //默认使用正方形

        return AspectRatio(
          aspectRatio: ratio,
          child: _buildImageItem(url),
        );
      },
    );
  }

  // 当动态附件为图片是创建网格页面
  Widget _buildImageGrid(List<String> urls) {
    final itemCount = urls.length > 9 ? 9 : urls.length;
    final crossAxisCount = urls.length == 1 ? 1 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: urls.length == 1 ? 1 : 1, // 基础比例，实际由图片决定
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (urls.length > 9 && index == 8) {
          return _buildOverflowThumbnail(urls.length - 9, urls[index]);
        }
        return urls.length == 1
            ? _buildSingleImage(urls[index])
            : _buildGridImage(urls[index]);
      },
    );
  }

  // 构建网格图片（固定正方形）
  Widget _buildGridImage(String url) {
    return AspectRatio(
      aspectRatio: 1,
      child: _buildImageItem(url),
    );
  }

  // 构建超过显示数量的缩略图
  Widget _buildOverflowThumbnail(int remainingCount, String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 实际图片内容
        _buildImageItem(imageUrl),

        // 遮罩层
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Colors.transparent,
                Color.fromRGBO(0, 0, 0, 0.7),
              ])),
        ),

        // 数量提示
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 获取图片尺寸
  Future<Size> _getImageSize(String imageUrl) {
    final completer = Completer<Size>();
    // TODO: 修改代码为从网络获取图片
    final image = Image.asset(imageUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    return completer.future;
  }

  // 当动态附件为视频时，创建视频预览页面
  Widget _buildVideoPreview(String videoUrl) {
    return GestureDetector(
      onTap: () {
        // TODO: 处理视频点击事件
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TODO: 改为从网络获取图片资源
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(videoUrl, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: const Icon(Icons.play_circle_outline,
                size: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 当动态附件为动态引用时，创建动态页面
  Widget _buildQuoteDynamic(Dynamic quotedDynamic) {
    return GestureDetector(
      onTap: () {
        // TODO: 处理动态点击事件
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: DynamicItem(dynamic: quotedDynamic),
      ),
    );
  }

  // 格式化时间
  String _formatTime(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inDays > 0) return '${duration.inDays}天前';
    if (duration.inHours > 0) return '${duration.inHours}小时前';
    if (duration.inMinutes > 0) return '${duration.inMinutes}分钟前';
    return '刚刚';
  }
}
