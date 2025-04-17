import 'package:flutter/material.dart';

import '../user_pages/profile_page_for_others.dart';

class VideoInfoPage extends StatefulWidget {
  const VideoInfoPage({super.key});

  @override
  State<VideoInfoPage> createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  // 折叠状态
  bool _isExpanded = false;

  // 关注状态
  bool _isFollowed = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: 各元素区域
          // UP 主信息区域
          _buildUploaderInfo(),
          // 折叠区域
          _buildCollapsibleSection(),
          // 占位滚动列表
          _buildVideoList(),
        ],
      ),
    );
  }



  // 构建 UP 主信息组件
  Widget _buildUploaderInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // UP 主头像
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePageForOthers()));
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: CircleAvatar(
              radius: 24,
              // TODO: 从网络获取头像
              // backgroundImage: NetworkImage(url),
              backgroundImage: AssetImage('assets/user_info/user_avatar3.jpg'),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          // 用户信息
          Expanded(
              child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePageForOthers()));
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户名',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '粉丝: 1.2W  作品: 34',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )),

          // 关注按钮
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isFollowed = !_isFollowed;
              });
              // TODO: 实现关注取关逻辑
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              backgroundColor:
                  _isFollowed ? Colors.grey[400] : Colors.pinkAccent,
              foregroundColor: _isFollowed ? Colors.grey[600] : Colors.white,
            ),
            child: Text(
              _isFollowed ? '已关注' : '+关注',
            ),
          ),
        ],
      ),
    );
  }

  // 折叠区域组件
  Widget _buildCollapsibleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 折叠头
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
            }),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '这是一个非常长的视频标题需要被截断处理...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '播放量：12.3w 次  2023-08-20 发布',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),

          // 折叠动画
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Container(),
            secondChild: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  // 展开后的详细内容
  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          '视频简介：这是一个非常详细的视频简介内容，用户展示视频的详细信息...',
          style: TextStyle(color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('科技')),
            Chip(label: Text('数码')),
            Chip(label: Text('评测')),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 构建视频列表
  Widget _buildVideoList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) => _buildVideoCard(index),
    );
  }

  // 构建单个视频卡片组件
  Widget _buildVideoCard(int index) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // TODO: 实现具体的点击逻辑
      onTap: () => print('Click $index'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 视频封面
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                // TODO: 实现从网络获取视频封面
                //  Image.network('assets/user_info/user_avatar1.jpg'),
                child: Image.asset(
                  'assets/user_info/user_avatar1.jpg',
                  fit: BoxFit.cover,
                  width: 125,
                  height: 100,
                  // height: double.infinity,
                ),
              ),

              const SizedBox(width: 16),
              // 视频信息列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频标题
                    Text(
                      '这是一个两行的视频标题，当文字过长时会自动截断处理...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // UP 主信息行
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '科技评测君',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // 数据统计行
                    Row(
                      children: [
                        _buildStatItem(Icons.play_arrow, '2.3w'),
                        const SizedBox(width: 16),
                        _buildStatItem(Icons.comment, '1.2k'),
                        // 推挤右侧图标
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.more_vert, size: 20),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // TODO: 实现点击事件
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建统计信息组件
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
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

  // TODO: 实现点击用户头像或信息跳转用户主页的逻辑
  void _handleUserProfilePage() {}
}
