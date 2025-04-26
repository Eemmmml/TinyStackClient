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
            setState(() {
              // _isExpanded[index] = !_isExpanded[index];
              _isExpanded[index] = isExpanded;
            });
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
      floatingActionButton: Visibility(
        visible: _selectedFriendCount > 0,
        child: FloatingActionButton.extended(
          onPressed: _confirmInvitation,
          backgroundColor: Colors.blue,
          icon: Icon(Icons.check_rounded, color: Colors.white),
          label: Text(
            '确定 $_selectedFriendCount',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          border: Border.all(width: 0.5, color: Colors.grey),
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
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildSelectedButton(friend),
            const SizedBox(width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(friend.avatarUrl),
                  radius: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  friend.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ));
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
      return;
    }

    // 实际业务逻辑示例
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认邀请'),
        content: Text('即将邀请 ${selectedIds.length} 位好友'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 调用实际的API接口实现邀请逻辑
              _sendInvitationRequest(selectedIds);

              Navigator.pop(context);
            },
            child: Text('确认'),
          ),
        ],
      ),
    );
  }

  // 模拟邀请用户的 API 调用
  void _sendInvitationRequest(List<String> userIds) async {
    try {
      // TODO：替换为实际的 API
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('邀请信息发送成功')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('发送邀请失败 $e')));
    }
  }
}
