import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

import '../../entity/group_item.dart';

class GroupMembersPage extends StatefulWidget {
  final GroupItem group;

  const GroupMembersPage({super.key, required this.group});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  late final IndexedScrollController _scrollController;
  final Map<String, int> _indexMap = {};
  List<String> _indexLetters = [];
  List<Widget> _listItems = [];
  final double _itemHeight = 36.0;

  @override
  void initState() {
    super.initState();
    _scrollController = IndexedScrollController();
    _prepareData();
    _addScrollListener();
  }

  void _addScrollListener() {
    _scrollController.addListener(() {
      // 计算有效滚动范围（基于item数量和item高度）
      final maxScrollOffset = (_listItems.length - 1) * _itemHeight;

      // 限制滚动偏移量在 [0, maxScrollOffset] 范围内
      if (_scrollController.offset < 0 ||
          _scrollController.offset > maxScrollOffset) {
        final clampedOffset =
            _scrollController.offset.clamp(0.0, maxScrollOffset);
        _scrollController.jumpTo(clampedOffset); // 修正到有效范围
      }
    });
  }

  void _prepareData() {
    final groupedMembers = _groupMembers(widget.group.members);
    _listItems = _buildListItems(groupedMembers);
    _buildIndexMap(groupedMembers);
  }

  Map<String, List<Member>> _groupMembers(List<Member> members) {
    final validMembers = members.where((m) => m.name.isNotEmpty).toList();
    final groups = <String, List<Member>>{};

    // 特殊角色分组
    final groupLeader =
        validMembers.where((m) => m.tag == MemberRole.groupLeader).toList();
    if (groupLeader.isNotEmpty) groups['↑'] = groupLeader;

    final admins =
        validMembers.where((m) => m.tag == MemberRole.administrator).toList();
    if (admins.isNotEmpty) groups['☆'] = admins;

    // 普通成员分组
    final normalMembers =
        validMembers.where((m) => m.tag == MemberRole.member).toList();
    normalMembers.sort((a, b) => a.inEnglishWord.compareTo(b.inEnglishWord));

    for (final member in normalMembers) {
      final letter = member.inEnglishWord.substring(0, 1).toUpperCase();
      groups.putIfAbsent(letter, () => []).add(member);
    }

    // 过滤空分组
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  void _buildIndexMap(Map<String, List<Member>> groups) {
    _indexMap.clear();
    _indexLetters = [];
    int position = 0;

    final orderedGroups = _getOrderedGroups(groups);
    for (final entry in orderedGroups) {
      final members = entry.value;
      if (members.isEmpty) continue;

      _indexMap[entry.key] = position;
      _indexLetters.add(entry.key);
      position += members.length + 1; // 标题 + 成员数
    }
  }

  List<MapEntry<String, List<Member>>> _getOrderedGroups(
      Map<String, List<Member>> groups) {
    final ordered = <MapEntry<String, List<Member>>>[];
    if (groups.containsKey('↑')) ordered.add(MapEntry('↑', groups['↑']!));
    if (groups.containsKey('☆')) ordered.add(MapEntry('☆', groups['☆']!));
    ordered.addAll(
        groups.entries.where((e) => !['↑', '☆'].contains(e.key)).toList()
          ..sort((a, b) => a.key.compareTo(b.key)));
    return ordered;
  }

  List<Widget> _buildListItems(Map<String, List<Member>> groups) {
    final items = <Widget>[];
    final orderedGroups = _getOrderedGroups(groups);

    for (final entry in orderedGroups) {
      final title = _getGroupTitle(entry.key);
      final members = entry.value;

      items.add(_buildSectionHeader(title, members.length));
      items.addAll(members.map(_buildMemberItem));
    }

    return items;
  }

  String _getGroupTitle(String symbol) {
    return {
          '↑': '群主',
          '☆': '管理员',
        }[symbol] ??
        symbol;
  }

  Widget _buildIndexBar() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: 24,
        margin: const EdgeInsets.only(top: 48),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _indexLetters.length,
          itemBuilder: (context, index) {
            final letter = _indexLetters[index];
            return GestureDetector(
              onTap: () => _scrollToIndex(letter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Text(
                        letter == '↑'
                            ? '↑'
                            : letter == '☆'
                                ? '☆'
                                : letter,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _scrollToIndex(String letter) {
    final targetPosition = _indexMap[letter];
    if (targetPosition == null) return;

    final maxScrollOffset = (_listItems.length - 1) * _itemHeight;
    final safeOffset =
        (targetPosition * _itemHeight).clamp(0.0, maxScrollOffset);

    _scrollController.jumpTo(safeOffset); // 使用绝对偏移量跳转
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('群聊成员'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_listItems.isEmpty) {
      return const Center(child: Text('暂无成员'));
    }

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // 拦截越界滚动
            if (notification is ScrollEndNotification) {
              final metrics = notification.metrics;
              if (metrics.outOfRange) {
                final clamped =
                    metrics.pixels.clamp(0, metrics.maxScrollExtent);
                if (clamped != metrics.pixels) {
                  _scrollController.jumpTo(clamped as double);
                }
              }
            }
            return false;
          },
          child: IndexedListView.builder(
            physics: const ClampingScrollPhysics(),
            controller: _scrollController,
            maxItemCount: _listItems.length,
            itemBuilder: (context, index) {
              if (index < 0 || index >= _listItems.length) return null;
              return _listItems[index];
            },
          ),
        ),
        _buildIndexBar(),
      ],
    );
  }

  void _showSearchPage() {
    // 搜索功能实现
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(Member member) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(member.avatarUrl)),
      title: Row(
        children: [
          _buildRoleTag(member.tag),
          const SizedBox(width: 8),
          Text(member.name),
        ],
      ),
    );
  }

  Widget _buildRoleTag(MemberRole role) {
    final textInfo = {
      MemberRole.groupLeader: {'text': '群主', 'color': Colors.red},
      MemberRole.administrator: {'text': '管理员', 'color': Colors.blue},
      MemberRole.member: {'text': '成员', 'color': Colors.grey},
    }[role]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: (textInfo['color']! as Color).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        textInfo['text']! as String,
        style: TextStyle(color: textInfo['color'] as Color, fontSize: 8),
      ),
    );
  }
}
