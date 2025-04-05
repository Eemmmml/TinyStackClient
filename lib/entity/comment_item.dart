class Comment {
  final String avatar;
  final String username;
  final String time;
  final String ip;
  final String content;
  final int likeCount;
  final int dislikeCount;
  final List<Reply> replies;
  final bool isAuthor;

  Comment(
      {required this.avatar,
      required this.username,
      required this.time,
      required this.ip,
      required this.content,
      required this.likeCount,
      required this.dislikeCount,
      this.replies = const [],
      this.isAuthor = false});

  // 测试模拟数据
  // TODO: 后续数据通过网络从后端服务获取
  static List<Comment> get comments {
    return [
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '科技爱好者',
        time: '1天前',
        ip: '北京',
        content: '画面清晰度惊人，运镜专业度堪比纪录片！',
        likeCount: 892,
        dislikeCount: 12,
        replies: [
          Reply(
            username: '摄影指导',
            tag: '团队',
            content: '我们使用了最新的RED摄影机拍摄~',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '美食家老张',
        time: '5分钟前',
        ip: '四川',
        content: '辣椒油的特写镜头看得人口水直流！',
        likeCount: 432,
        dislikeCount: 8,
        replies: [
          Reply(
            username: 'UP主',
            tag: 'UP',
            content: '特意去四川学的秘方哦！',
          ),
          Reply(
            username: '吃货小分队',
            tag: '认证用户',
            content: '求店铺地址！',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '旅行蛙',
        time: '3小时前',
        ip: '云南',
        content: '航拍洱海的镜头太治愈了，已设为壁纸！',
        likeCount: 1567,
        dislikeCount: 23,
        replies: [],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '历史迷',
        time: '6小时前',
        ip: '陕西',
        content: '第8分钟的历史考据有点小问题，建议再核实下',
        likeCount: 78,
        dislikeCount: 45,
        replies: [
          Reply(
            username: 'UP主',
            tag: 'UP',
            content: '感谢指正！已置顶说明',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '音乐达人',
        time: '昨天',
        ip: '上海',
        content: 'BGM选得太绝了，求歌单合集！',
        likeCount: 2304,
        dislikeCount: 9,
        replies: [
          Reply(
            username: '音频组',
            tag: '团队',
            content: '稍后会在动态发布完整歌单',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '健身狂魔',
        time: '2小时前',
        ip: '江苏',
        content: '动作讲解非常详细，适合新手跟练！',
        likeCount: 345,
        dislikeCount: 6,
        replies: [
          Reply(
            username: 'UP主',
            tag: 'UP',
            content: '每周三更新训练计划~',
          ),
          Reply(
            username: '瑜伽爱好者',
            tag: '粉丝',
            content: '跟着练了一周确实有效！',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '数码控',
        time: '4天前',
        ip: '广东',
        content: '手机测评数据非常专业，已三连支持！',
        likeCount: 1562,
        dislikeCount: 18,
        replies: [],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '小说家',
        time: '12分钟前',
        ip: '浙江',
        content: '剧情解说的节奏把控完美，声线也超有磁性！',
        likeCount: 89,
        dislikeCount: 2,
        replies: [
          Reply(
            username: '配音演员',
            tag: '团队',
            content: '感谢认可！我们会继续努力',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '萌宠日记',
        time: '1小时前',
        ip: '重庆',
        content: '猫猫的慢镜头太可爱了，心都化了！',
        likeCount: 2451,
        dislikeCount: 15,
        replies: [
          Reply(
            username: 'UP主',
            tag: 'UP',
            content: '主子听到夸奖会骄傲的~',
          ),
          Reply(
            username: '云吸猫协会',
            tag: '官方',
            content: '建议出猫咪特辑！',
          )
        ],
      ),
      Comment(
        avatar: 'assets/user_info/user_avatar.jpg',
        username: '考研党',
        time: '3天前',
        ip: '湖北',
        content: '学习干货满满，笔记已经记了五页纸！',
        likeCount: 678,
        dislikeCount: 7,
        replies: [
          Reply(
            username: 'UP主',
            tag: 'UP',
            content: '加油！上岸记得来报喜~',
          )
        ],
      )
    ];
  }
}

class Reply {
  final String username;
  final String content;
  final String? tag;

  Reply({required this.username, required this.content, this.tag});
}
