// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_detail_pojo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoDetailPojo _$VideoDetailPojoFromJson(Map<String, dynamic> json) =>
    VideoDetailPojo(
      id: (json['id'] as num).toInt(),
      uploaderId: (json['uploaderId'] as num).toInt(),
      uploaderName: json['uploaderName'] as String,
      uploaderAvatarUrl: json['uploaderAvatarUrl'] as String,
      fans: (json['fans'] as num).toInt(),
      compositions: (json['compositions'] as num).toInt(),
      isFollowed: json['isFollowed'] as bool,
      title: json['title'] as String,
      videoSource: json['videoSource'] as String,
      viewCount: (json['viewCount'] as num).toInt(),
      tabs: json['tabs'] as String,
      description: json['description'] as String,
      uploadTime: DateTime.parse(json['uploadTime'] as String),
    );

Map<String, dynamic> _$VideoDetailPojoToJson(VideoDetailPojo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploaderId': instance.uploaderId,
      'uploaderName': instance.uploaderName,
      'uploaderAvatarUrl': instance.uploaderAvatarUrl,
      'fans': instance.fans,
      'compositions': instance.compositions,
      'isFollowed': instance.isFollowed,
      'title': instance.title,
      'videoSource': instance.videoSource,
      'description': instance.description,
      'viewCount': instance.viewCount,
      'tabs': instance.tabs,
      'uploadTime': instance.uploadTime.toIso8601String(),
    };
