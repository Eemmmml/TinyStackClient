// 视频合集数据模型
class VideoCollection {
  final String coverUrl;
  final String title;
  final String playCount;
  final String commentCount;
  final String videoCount;

  VideoCollection({
    required this.coverUrl,
    required this.title,
    required this.playCount,
    required this.commentCount,
    required this.videoCount,
  });

  static List<VideoCollection> getDummyCollections() {
    // 模拟数据
    return [
      VideoCollection(
        coverUrl: 'https://picsum.photos/300/400',
        title: '我的旅行日记合集我的旅行日记合集我的旅行日记合集我的旅行日记合集',
        playCount: '1.2万',
        commentCount: '356',
        videoCount: '8',
      ),
      VideoCollection(
        coverUrl: 'https://picsum.photos/300/400',
        title: '我的旅行日记合集',
        playCount: '1.2万',
        commentCount: '356',
        videoCount: '8',
      ),
      VideoCollection(
        coverUrl: 'https://picsum.photos/300/400',
        title: '我的旅行日记合集',
        playCount: '1.2万',
        commentCount: '356',
        videoCount: '8',
      ),
      VideoCollection(
        coverUrl: 'https://picsum.photos/300/400',
        title: '我的旅行日记合集',
        playCount: '1.2万',
        commentCount: '356',
        videoCount: '8',
      ),
      VideoCollection(
        coverUrl: 'https://picsum.photos/300/400',
        title: '我的旅行日记合集',
        playCount: '1.2万',
        commentCount: '356',
        videoCount: '8',
      ),
    ];
  }
}
