import 'package:json_annotation/json_annotation.dart';

part 'user_basic_info.g.dart';

@JsonSerializable()
class UserBasicInfo {
  // 用户名
  String username;

  // 用户背景图片地址
  String backgroundImageUrl;

  // 头像图片地址
  String avatarImageUrl;

  // 个人简介
  String description;

  // 我的关注数量
  int interests;

  // 我的作品数量
  int compositions;

  // 我的粉丝数量
  int fans;

  UserBasicInfo(
      {required this.username,
        required this.backgroundImageUrl,
      required this.avatarImageUrl,
      required this.description,
      required this.interests,
      required this.compositions,
      required this.fans});

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$UserBasicInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserBasicInfoToJson(this);

  static List<UserBasicInfo> get userBasicInfos {
    return [
      UserBasicInfo(
        username: 'Eemmmml',
        backgroundImageUrl: 'https://picsum.photos/1000/800?random=4',
        avatarImageUrl: 'assets/user_info/user_avatar.jpg',
        description: '这个人很懒，什么也没有留下~',
        interests: 211,
        compositions: 323,
        fans: 1000000,
      ),
      UserBasicInfo(
        username: 'Kevin',
        backgroundImageUrl: 'https://picsum.photos/1000/800?random=4',
        avatarImageUrl: 'assets/user_info/user_avatar2.jpg',
        description: '这个人很懒，什么也没有留下~',
        interests: 477,
        compositions: 871,
        fans: 500000,
      ),
      UserBasicInfo(
        username: 'Jack',
        backgroundImageUrl: 'https://picsum.photos/1000/800?random=4',
        avatarImageUrl: 'assets/user_info/user_avatar1.jpg',
        description: '这个人很懒，什么也没有留下~',
        interests: 452,
        compositions: 879,
        fans: 2000000,
      ),
    ];
  }

  static UserBasicInfo get myUserBasicInfo {
    return UserBasicInfo(
      username: 'Eemmmml',
      backgroundImageUrl: 'https://picsum.photos/1000/800?random=4',
      avatarImageUrl: 'https://picsum.photos/200/200?random=4',
      description: '这个人很懒，什么也没有留下~',
      interests: 211,
      compositions: 323,
      fans: 1000000,
    );
  }
}
