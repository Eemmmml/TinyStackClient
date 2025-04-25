import 'package:flutter/material.dart';

import '../../entity/friend.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  // 下拉列表的展开状态
  final List<bool> _isExpanded = [true, true];

  // 合并后的好友列表
  late List<Friend> _allFriends;

  @override
  void initState() {
    super.initState();
    _allFriends = [
      ...FriendRepository.getRecentFriends(),
      ...FriendRepository.getAllFriends(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final recentFriends =
        _allFriends.where((friend) => friend.isRecent).toList();
    final othersFriends =
        _allFriends.where((friend) => !friend.isRecent).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('邀请新成员'),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            _isExpanded[index] = !isExpanded;
          },
          children: [
            _buildSection(
                title: '最近联系人 (${recentFriends.length})',
                friends: recentFriends,
                sectionIndex: 0),
            _buildSection(
                title: '其他好友 (${othersFriends.length})',
                friends: othersFriends,
                sectionIndex: 1),
          ],
        ),
      ),
    );
  }

  // 构建选择按钮
  Widget _buildSelectedButton(Friend friend) {
    final bool isDisabled = friend.isInGroup;

    return GestureDetector(
      onTap: isDisabled ? null : () => _toggleFriendSelection(friend),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
          ),
          color: _getButtonColor(friend),
        ),
        child: _shouldShowCheckmark(friend)
            ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  // 构建好友列表列表项
  Widget _buildFriendListItem(Friend friend) {
    return ListTile(
      leading: _buildSelectedButton(friend),
      title: CircleAvatar(
        backgroundImage: NetworkImage(friend.avatarUrl),
      ),
      trailing: Text(
        friend.username,
      ),
    );
  }

  // 构建可折叠面板
  ExpansionPanel _buildSection(
      {required String title,
      required List<Friend> friends,
      required int sectionIndex}) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      body: Column(
        children: friends.map(_buildFriendListItem).toList(),
      ),
      isExpanded: _isExpanded[sectionIndex],
    );
  }

  // 获取按钮的颜色
  Color _getButtonColor(Friend friend) {
    if (friend.isInGroup) return Colors.grey;
    if (friend.isSelected) return Colors.blue;
    return Colors.white;
  }

  // 按钮中是否需要展示对勾
  bool _shouldShowCheckmark(Friend friend) {
    return friend.isSelected || friend.isInGroup;
  }

  // 切换好友选择状态
  void _toggleFriendSelection(Friend friend) {
    setState(() {
      friend.isSelected = !friend.isSelected;
    });
  }

  // 获取选中好友数量
  int get _selectedFriendCount => _allFriends
      .where((friend) => friend.isSelected && !friend.isInGroup)
      .length;

  // 确认邀请
  void _confirmInvitation() {
    final selectedIds = _allFriends
        .where((friend) => friend.isSelected && !friend.isInGroup)
        .map((friend) => friend.id)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请至少选择一位好友')));
    }
  }
}
