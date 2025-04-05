class UserBasicInfo {
  // 用户名
  String username;

  // 头像图片地址
  String avatarImageUrl;

  // 个人简介
  String description;

  // 我的关注数量
  String interests;

  // 我的作品数量
  String compositions;

  // 我的粉丝数量
  String fans;

  UserBasicInfo(
      {required this.username,
      required this.avatarImageUrl,
      required this.description,
      required this.interests,
      required this.compositions,
      required this.fans});

  static List<UserBasicInfo> get userBasicInfos {
    return [
      UserBasicInfo(
        username: 'Eemmmml',
        avatarImageUrl: 'assets/user_info/user_avatar.jpg',
        description: '这个人很懒，什么也没有留下~',
        interests: '211',
        compositions: '323',
        fans: '100w',
      ),
      UserBasicInfo(
        username: 'Kevin',
        avatarImageUrl: 'assets/user_info/user_avatar2.jpg',
        description: '这个人很懒，什么也没有留下~',
        interests: '477',
        compositions: '871',
        fans: '50w',
      ),
      UserBasicInfo(
        username: 'Jack',
        avatarImageUrl: 'assets/user_info/user_avatar1.jpg',
        description: '这个人很懒，什么也没有留下~',
        interests: '452',
        compositions: '879',
        fans: '200w',
      ),
    ];
  }

  static UserBasicInfo get myUserBasicInfo {
    return UserBasicInfo(
      username: 'Eemmmml',
      avatarImageUrl: 'assets/user_info/user_avatar.jpg',
      description: '这个人很懒，什么也没有留下~',
      interests: '211',
      compositions: '323',
      fans: '100w',
    );
  }
}
