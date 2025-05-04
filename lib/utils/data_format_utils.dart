class DataFormatUtils {

  // 时间格式化代码
  static String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // 数据格式化代码
  static String formatNumber(int num) {
    if (num >= 10000) {
      double value = num / 10000;
      String formatted = value.toStringAsFixed(1);
      if (formatted.endsWith('.0')) {
        return '${value.toInt()}w';
      } else {
        return '$formatted w'.replaceAll(' ', ''); // 移除空格，确保格式紧凑
      }
    } else if (num >= 1000) {
      double value = num / 1000;
      String formatted = value.toStringAsFixed(1);
      if (formatted.endsWith('.0')) {
        return '${value.toInt()}k';
      } else {
        return '$formatted k'.replaceAll(' ', '');
      }
    } else {
      return num.toString();
    }
  }
}