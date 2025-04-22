class User {
  final String id;
  final String username;
  final String avatarUrl;
  final int followersCount;
  final int postsCount;
  final String bio;
  bool isFollowing;

  User({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.followersCount,
    required this.postsCount,
    required this.bio,
    this.isFollowing = false,
  });
}

extension NumberFormatting on int {
  String formatCount() {
    if (this >= 10000) {
      final value = this / 10000;
      return _formatWithCondition(value, 'w');
    } else if (this >= 1000) {
      final value = this / 1000;
      return _formatWithCondition(value, 'k');
    }
    return toString();
  }

  String _formatWithCondition(double value, String unit) {
    // 四舍五入到一位小数
    final formatted = value.toStringAsFixed(1);
    // 分离整数和小数部分
    final parts = formatted.split('.');
    // 如果小数部分是 0 则只显示整数
    if (parts[1] == '0') {
      return '${parts[0]}$unit';
    }
    // 否则显示完整格式
    return "${formatted.replaceFirst(RegExp(r'.0$'), '')}$unit";
  }
}
