// 用户主页的基本用户信息
class User {
  final String id;
  final String username;
  final String avatarUrl;

  User({required this.id, required this.username, required this.avatarUrl});
}

// 动态附件类型
enum AttachmentType { image, video, quote }

// 动态附件数据模型
class Attachment {
  final AttachmentType type;

  // 图片/视频 URL 列表
  final List<String>? urls;

  // 引用的动态
  final Dynamic? quotedDynamic;

  Attachment.image(List<String> urls)
      : type = AttachmentType.image,
        urls = urls,
        quotedDynamic = null;

  Attachment.video(String videoUrl)
      : type = AttachmentType.video,
        urls = [videoUrl],
        quotedDynamic = null;

  Attachment.quote(Dynamic dynamic)
      : type = AttachmentType.quote,
        urls = null,
        quotedDynamic = dynamic;
}

// 动态数据
class Dynamic {
  final User user;
  final DateTime publishTime;
  final String content;
  final List<Attachment> attachments;
  final int shareCount;
  final int commentCount;
  int likeCount;
  bool isLiked;

  Dynamic({
    required this.user,
    required this.publishTime,
    required this.content,
    required this.attachments,
    required this.shareCount,
    required this.commentCount,
    required this.likeCount,
    this.isLiked = false,
  });

  static List<Dynamic> dynamics() {
    return [
      Dynamic(
        user: User(
          id: '1',
          username: 'Flutter 开发者',
          avatarUrl: 'assets/user_info/user_avatar1.jpg',
        ),
        publishTime: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            '这是一个示例动态内容，包含一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的文本',
        attachments: [
          Attachment.image([
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
          ]),
        ],
        shareCount: 42,
        commentCount: 15,
        likeCount: 88,
        isLiked: true,
      ),
      Dynamic(
        user: User(
          id: '1',
          username: 'Flutter 开发者',
          avatarUrl: 'assets/user_info/user_avatar1.jpg',
        ),
        publishTime: DateTime.now().subtract(const Duration(hours: 2)),
        content: '这是一个示例动态内容',
        attachments: [
          Attachment.image([
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
          ]),
        ],
        shareCount: 42,
        commentCount: 15,
        likeCount: 88,
      ),
      Dynamic(
        user: User(
          id: '1',
          username: 'Flutter 开发者',
          avatarUrl: 'assets/user_info/user_avatar1.jpg',
        ),
        publishTime: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            '这是一个示例动态内容，包含一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的文本',
        attachments: [
          Attachment.image([
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
          ]),
        ],
        shareCount: 42,
        commentCount: 15,
        likeCount: 88,
      ),
      Dynamic(
        user: User(
          id: '1',
          username: 'Flutter 开发者',
          avatarUrl: 'assets/user_info/user_avatar1.jpg',
        ),
        publishTime: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            '这是一个示例动态内容，包含一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的文本',
        attachments: [
          Attachment.image([
            'https://picsum.photos/200/300',
          ]),
        ],
        shareCount: 42,
        commentCount: 15,
        likeCount: 88,
      ),
      Dynamic(
        user: User(
          id: '1',
          username: 'Flutter 开发者',
          avatarUrl: 'assets/user_info/user_avatar1.jpg',
        ),
        publishTime: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            '这是一个示例动态内容，包含一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的文本',
        attachments: [
          Attachment.quote(
            Dynamic(
              user: User(
                id: '1',
                username: 'Flutter 开发者',
                avatarUrl: 'assets/user_info/user_avatar1.jpg',
              ),
              publishTime: DateTime.now().subtract(const Duration(hours: 2)),
              content:
                  '这是一个示例动态内容，包含一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的文本',
              attachments: [
                Attachment.image([
                  'https://picsum.photos/200/300',
                ]),
              ],
              shareCount: 42,
              commentCount: 15,
              likeCount: 88,
            ),
          ),
        ],
        shareCount: 42,
        commentCount: 15,
        likeCount: 88,
      ),
      Dynamic(
        user: User(
          id: '1',
          username: 'Flutter 开发者',
          avatarUrl: 'assets/user_info/user_avatar1.jpg',
        ),
        publishTime: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            '这是一个示例动态内容，包含一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的文本',
        attachments: [
          Attachment.video('assets/user_background.png'),
        ],
        shareCount: 42,
        commentCount: 15,
        likeCount: 88,
      ),
    ];
  }
}

// 交互统计
class InteractionsStats {
  final int shareCount;
  final int commentCount;
  final int likeCount;

  InteractionsStats(
      {required this.shareCount,
      required this.commentCount,
      required this.likeCount});
}
