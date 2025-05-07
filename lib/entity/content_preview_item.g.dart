// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_preview_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentPreviewItem _$ContentPreviewItemFromJson(Map<String, dynamic> json) =>
    ContentPreviewItem(
      id: (json['id'] as num?)?.toInt(),
      authorID: (json['authorID'] as num?)?.toInt(),
      title: json['title'] as String,
      author: json['author'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$ContentPreviewItemToJson(ContentPreviewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorID': instance.authorID,
      'title': instance.title,
      'author': instance.author,
      'imageUrl': instance.imageUrl,
    };
