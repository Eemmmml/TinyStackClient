import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tinystack/entity/group_item.dart';

class GroupMembersPage extends StatefulWidget {
  const GroupMembersPage({super.key});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  // 原始成员列表
  final List<Member> members = [];

  // 按字母分组的成员
  final Map<String, List<Member>> groupedMembers = {};

  // 分组标题列表
  final List<String> sectionTitles = [];

  // 页面滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 记录每个滚动的位置
  final Map<String, int> sectionIndices = {};

  @override
  void initState() {
    super.initState();
    // 生成数据示例
    _generateMockData();
    // 处理数据分组
    _groupMembers();
    // 延迟位置计算
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _calculateSectionIndices());
  }

  void _generateMockData() {
    members.addAll([
      Member(
          id: '1',
          name: '张三',
          avatarUrl: 'https://picsum.photos/200/200?random=2',
          tag: MemberRole.groupLeader,
          inEnglishWord: 'Z'),
      Member(
          id: '2',
          name: '李四',
          avatarUrl: 'https://picsum.photos/200/200?random=2',
          tag: MemberRole.administrator,
          inEnglishWord: 'L'),
      Member(
          id: '3',
          name: '王五',
          avatarUrl: 'https://picsum.photos/200/200?random=2',
          tag: MemberRole.administrator,
          inEnglishWord: 'W'),
      Member(
          id: '4',
          name: 'Alice',
          avatarUrl: 'https://picsum.photos/200/200?random=2',
          tag: MemberRole.member,
          inEnglishWord: 'A'),
      Member(
          id: '5',
          name: 'Bob',
          avatarUrl: 'https://picsum.photos/200/200?random=2',
          tag: MemberRole.member,
          inEnglishWord: 'B'),
      Member(
        id: '1',
        name: '阿明',
        avatarUrl: 'https://picsum.photos/200/200?random=A',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'A',
      ),
      Member(
        id: '2',
        name: '鲍勃',
        avatarUrl: 'https://picsum.photos/200/200?random=B',
        tag: MemberRole.member,
        inEnglishWord: 'B',
      ),
      Member(
        id: '3',
        name: '查理',
        avatarUrl: 'https://picsum.photos/200/200?random=C',
        tag: MemberRole.member,
        inEnglishWord: 'C',
      ),
      Member(
        id: '4',
        name: '大卫',
        avatarUrl: 'https://picsum.photos/200/200?random=D',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'D',
      ),
      Member(
        id: '5',
        name: '艾丽',
        avatarUrl: 'https://picsum.photos/200/200?random=E',
        tag: MemberRole.administrator,
        inEnglishWord: 'E',
      ),
      Member(
        id: '6',
        name: '弗兰克',
        avatarUrl: 'https://picsum.photos/200/200?random=F',
        tag: MemberRole.member,
        inEnglishWord: 'F',
      ),
      Member(
        id: '7',
        name: '格蕾丝',
        avatarUrl: 'https://picsum.photos/200/200?random=G',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'G',
      ),
      Member(
        id: '8',
        name: '亨利',
        avatarUrl: 'https://picsum.photos/200/200?random=H',
        tag: MemberRole.administrator,
        inEnglishWord: 'H',
      ),
      Member(
        id: '9',
        name: '伊莎贝拉',
        avatarUrl: 'https://picsum.photos/200/200?random=I',
        tag: MemberRole.member,
        inEnglishWord: 'I',
      ),
      Member(
        id: '10',
        name: '杰克',
        avatarUrl: 'https://picsum.photos/200/200?random=J',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'J',
      ),
      Member(
        id: '11',
        name: '凯莉',
        avatarUrl: 'https://picsum.photos/200/200?random=K',
        tag: MemberRole.administrator,
        inEnglishWord: 'K',
      ),
      Member(
        id: '12',
        name: '李明',
        avatarUrl: 'https://picsum.photos/200/200?random=L',
        tag: MemberRole.member,
        inEnglishWord: 'L',
      ),
      Member(
        id: '13',
        name: '玛雅',
        avatarUrl: 'https://picsum.photos/200/200?random=M',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'M',
      ),
      Member(
        id: '14',
        name: '尼克',
        avatarUrl: 'https://picsum.photos/200/200?random=N',
        tag: MemberRole.administrator,
        inEnglishWord: 'N',
      ),
      Member(
        id: '15',
        name: '奥利维亚',
        avatarUrl: 'https://picsum.photos/200/200?random=O',
        tag: MemberRole.member,
        inEnglishWord: 'O',
      ),
      Member(
        id: '16',
        name: '彼得',
        avatarUrl: 'https://picsum.photos/200/200?random=P',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'P',
      ),
      Member(
        id: '17',
        name: ' Quincy',
        avatarUrl: 'https://picsum.photos/200/200?random=Q',
        tag: MemberRole.administrator,
        inEnglishWord: 'Q',
      ),
      Member(
        id: '18',
        name: '罗伯特',
        avatarUrl: 'https://picsum.photos/200/200?random=R',
        tag: MemberRole.member,
        inEnglishWord: 'R',
      ),
      Member(
        id: '19',
        name: '萨拉',
        avatarUrl: 'https://picsum.photos/200/200?random=S',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'S',
      ),
      Member(
        id: '20',
        name: '托马斯',
        avatarUrl: 'https://picsum.photos/200/200?random=T',
        tag: MemberRole.administrator,
        inEnglishWord: 'T',
      ),
      Member(
        id: '21',
        name: '乌苏拉',
        avatarUrl: 'https://picsum.photos/200/200?random=U',
        tag: MemberRole.member,
        inEnglishWord: 'U',
      ),
      Member(
        id: '22',
        name: '维克多',
        avatarUrl: 'https://picsum.photos/200/200?random=V',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'V',
      ),
      Member(
        id: '23',
        name: '温迪',
        avatarUrl: 'https://picsum.photos/200/200?random=W',
        tag: MemberRole.administrator,
        inEnglishWord: 'W',
      ),
      Member(
        id: '24',
        name: '夏洛克',
        avatarUrl: 'https://picsum.photos/200/200?random=X',
        tag: MemberRole.member,
        inEnglishWord: 'X',
      ),
      Member(
        id: '25',
        name: '叶莲娜',
        avatarUrl: 'https://picsum.photos/200/200?random=Y',
        tag: MemberRole.groupLeader,
        inEnglishWord: 'Y',
      ),
      Member(
        id: '26',
        name: '扎克',
        avatarUrl: 'https://picsum.photos/200/200?random=Z',
        tag: MemberRole.member,
        inEnglishWord: 'Z',
      ),
    ]);
  }

  void _groupMembers() {
    // 分离群主和管理员
    final admins =
    members.where((member) => member.tag != MemberRole.member).toList();
    final normalMembers =
    members.where((member) => member.tag == MemberRole.member).toList();

    // 处理普通成员分组
    final tempMap = <String, List<Member>>{};
    for (var member in normalMembers) {
      final firstLetter = member.inEnglishWord[0].toUpperCase();
      tempMap.putIfAbsent(firstLetter, () => []).add(member);
    }

    // 排序并生成最终数据
    sectionTitles.add('群主和管理员');
    groupedMembers['群主和管理员'] = admins;

    final sortLetters = tempMap.keys.toList()..sort();
    for (var letter in sortLetters) {
      sectionTitles.add(letter);
      groupedMembers[letter] = tempMap[letter] ?? [];
    }
  }

  void _calculateSectionIndices() {
    int index = 0;
    sectionIndices.clear();

    for (var title in sectionTitles) {
      sectionIndices[title] = index;
      // 每个分组占一个标题 + 成员数量
      index += groupedMembers[title]!.length + 1;
    }
  }

  void _scrollToSection(String section) {
    final targetIndex = sectionIndices[section];
    if (targetIndex != null) {
      _scrollController.animateTo(
        targetIndex * 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('群聊成员'),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _calculateTotalItems(),
              itemBuilder: (context, index) {
                return _buildListItem(index);
              },
            ),
          ),
          _buildAlphabetNav(),
        ],
      ),
    );
  }

  int _calculateTotalItems() {
    return sectionTitles.fold(
        0, (sum, title) => sum + groupedMembers[title]!.length + 1);
  }

  Widget _buildListItem(int index) {
    int current = 0;
    for (var title in sectionTitles) {
      final itemsCount = groupedMembers[title]!.length + 1;
      if (index < current + itemsCount) {
        final isTitle = index == current;
        return isTitle
            ? _buildSectionHeader(title)
            : _buildMemberItem(groupedMembers[title]![index - current - 1]);
      }
      current += itemsCount;
    }
    return SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title) {
    final count = groupedMembers[title]!.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        '$title ($count)',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // TODO: 样式需要更新
  Widget _buildMemberItem(Member member) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(member.avatarUrl),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildRoleTag(member.tag),
          const SizedBox(width: 8),
          Text(member.name),
        ],
      ),
    );
  }

  // 构建用户 Tag 组件
  Widget _buildRoleTag(MemberRole role) {
    switch (role) {
      case MemberRole.groupLeader:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '群主',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case MemberRole.administrator:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '管理员',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '群成员',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
    }
  }

  Widget _buildAlphabetNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: 24,
      child: Column(
        children: [
          Icon(Icons.search_rounded, size: 20),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero, // 移除ListView的内边距
              separatorBuilder: (context, index) => const SizedBox(height: 3),
              itemCount: 26,
              itemBuilder: (context, index) {
                final letter = String.fromCharCode(65 + index);
                return SizedBox(
                  // 固定宽度为24
                  width: 24,
                  child: GestureDetector(
                    onTap: () => _scrollToSection(letter),
                    child: Text(
                      letter,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center, // 文本居中对齐
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
