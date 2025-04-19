import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          const SizedBox(height: 15),
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
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 视频封面部分
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 150,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // 封面占位颜色
                        image: DecorationImage(
                            image: AssetImage('assets/user_background.png'),
                            fit: BoxFit.cover),
                      ),
                      // TODO: 从网络获取图片
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(Duration(minutes: 4, seconds: 20)),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '这是一个视频标题',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(
                            DateTime.now().subtract(Duration(hours: 2))),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 5),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoWithIcon(Icons.play_arrow, 120),
                          _buildInfoWithIcon(Icons.comment, 110),
                          IconButton(
                            icon: Icon(Icons.more_vert, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              // TODO: 实现按钮交互逻辑
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建Icon和数据结合的部分
  Widget _buildInfoWithIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          NumberFormat.compact().format(count),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 格式化视频发布时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
    }
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  // // 构建单个视频卡片组件
  // Widget _buildVideoCard(int index) {
  //   return InkWell(
  //     splashColor: Colors.transparent,
  //     highlightColor: Colors.transparent,
  //     // TODO: 实现具体的点击逻辑
  //     onTap: () => print('Click $index'),
  //     child: Card(
  //       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //       elevation: 2,
  //       child: Padding(
  //         padding: const EdgeInsets.all(12),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // 视频封面
  //             ClipRRect(
  //               borderRadius: BorderRadius.circular(6),
  //               // TODO: 实现从网络获取视频封面
  //               //  Image.network('assets/user_info/user_avatar1.jpg'),
  //               child: Image.asset(
  //                 'assets/user_info/user_avatar1.jpg',
  //                 fit: BoxFit.cover,
  //                 width: 125,
  //                 height: 100,
  //                 // height: double.infinity,
  //               ),
  //             ),
  //
  //             const SizedBox(width: 16),
  //             // 视频信息列
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // 视频标题
  //                   Text(
  //                     '这是一个两行的视频标题，当文字过长时会自动截断处理...',
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w500,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //
  //                   // UP 主信息行
  //                   Row(
  //                     children: [
  //                       Icon(Icons.person_outline,
  //                           size: 14, color: Colors.grey[600]),
  //                       const SizedBox(width: 4),
  //                       Text(
  //                         '科技评测君',
  //                         style: TextStyle(
  //                           color: Colors.grey[600],
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   // 数据统计行
  //                   Row(
  //                     children: [
  //                       _buildStatItem(Icons.play_arrow, '2.3w'),
  //                       const SizedBox(width: 16),
  //                       _buildStatItem(Icons.comment, '1.2k'),
  //                       // 推挤右侧图标
  //                       Spacer(),
  //                       IconButton(
  //                         icon: Icon(Icons.more_vert, size: 20),
  //                         padding: EdgeInsets.zero,
  //                         onPressed: () {
  //                           // TODO: 实现点击事件
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
