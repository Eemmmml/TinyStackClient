import 'package:lpinyin/lpinyin.dart';
// 社群数据模型
class GroupItem {
  final String id;
  final String groupName;
  final String avatarUrl;
  final String description;
  late int membersCount;
  final List<Member> members;
  bool isTop;
  bool isHide;
  bool isNotDisturb;

  GroupItem({
    required this.id,
    required this.groupName,
    required this.avatarUrl,
    required this.description,
    required this.membersCount,
    required this.members,
    this.isTop = false,
    this.isHide = false,
    this.isNotDisturb = false,
  });
}


// 修改后的Member模型
class Member {
  final String id;
  final String name;
  final String avatarUrl;
  final MemberRole tag;
  final String inEnglishWord;

  Member({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.tag = MemberRole.member,
    String? inEnglishWord,
  }) : inEnglishWord = inEnglishWord ?? _getFirstLetter(name);

  static String _getFirstLetter(String name) {
    return PinyinHelper.getFirstWordPinyin(name)
        .substring(0, 1)
        .toUpperCase();
  }
}

enum MemberRole {
  // 群主
  groupLeader,
  // 群管理
  administrator,
  // 群成员
  member,
}

class SettingItem {
  final String title;
  bool value;

  SettingItem({required this.title, this.value = false});

  static List<SettingItem> get settings => [
        SettingItem(title: '隐藏会话'),
        SettingItem(title: '置顶聊天'),
        SettingItem(title: '消息免打扰'),
      ];
}
