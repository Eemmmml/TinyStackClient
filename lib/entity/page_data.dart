import 'package:tinystack/entity/content_preview_item.dart';

class PageData {
  final List<ContentPreviewItem> items;
  final bool hasBanner;

  PageData({required this.items, required this.hasBanner});
}