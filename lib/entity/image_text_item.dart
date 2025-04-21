class ImageTextItem {
  final String title;
  final String imageUrl;
  final String content;
  final String category;
  final String viewCount;
  final String commentCount;

  ImageTextItem(
      {required this.title,
      required this.imageUrl,
      required this.content,
      required this.category,
      required this.viewCount,
      required this.commentCount});

  static List<ImageTextItem> getDummyPosts() {
    return [
      ImageTextItem(
        title: '春日樱花摄影技巧分享',
        imageUrl: 'https://picsum.photos/800/300',
        content: '拍摄樱花时要注意光线角度，建议使用逆光拍摄...',
        category: '摄影技巧',
        viewCount: '2.3万',
        commentCount: '189',
      ),
    ];
  }
}
