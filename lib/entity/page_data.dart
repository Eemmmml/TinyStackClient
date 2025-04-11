import 'package:tinystack/entity/item_content.dart';

class PageData {
  final List<ContentItem> items;
  final bool hasBanner;

  PageData({required this.items, required this.hasBanner});
}