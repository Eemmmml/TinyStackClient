import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../entity/group_item.dart';
import 'group_members_page.dart';
import 'invite_member_page.dart';

class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({super.key});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  // 社群的设置项
  final List<SettingItem> settings = SettingItem.settings;

  // 模拟数据
  final currentGroup = GroupItem(
    id: '1',
    groupName: 'Flutter开发者社区',
    avatarUrl: 'https://picsum.photos/200/200?random=2',
    description: '专注Flutter技术交流与经验分享的开发者社区',
    membersCount: 2356,
    members: List.generate(
        13,
        (i) => Member(
            id: 'm$i',
            name: '用户${i + 1}',
            avatarUrl: 'https://picsum.photos/200/200?random=${i + 1}')),
    isHide: true,
  );

  final recommendedGroups = [
    GroupItem(
      id: '2',
      groupName: 'Dart语言交流',
      avatarUrl: 'https://picsum.photos/200/200?random=2',
      description: 'Dart编程语言技术交流',
      membersCount: 856,
      members: List.generate(
          13,
          (i) => Member(
              id: 'm$i',
              name: '用户${i + 1}',
              avatarUrl: 'https://picsum.photos/200/200?random=${i + 1}')),
    ),
    GroupItem(
      id: '3',
      groupName: '移动开发前沿',
      avatarUrl: 'https://picsum.photos/200/200?random=2',
      description: '关注移动开发最新技术动态',
      membersCount: 3421,
      members: List.generate(
          13,
          (i) => Member(
              id: 'm$i',
              name: '用户${i + 1}',
              avatarUrl: 'https://picsum.photos/200/200?random=${i + 1}')),
    ),
  ];

  List<Member> _generateMockData() {
    return [
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
    ];
  }

  @override
  void initState() {
    settings[0].value = currentGroup.isHide;
    settings[1].value = currentGroup.isTop;
    settings[2].value = currentGroup.isNotDisturb;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('社区信息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 分享功能实现
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 社区基本信息卡片
          _buildGroupProfileCard(context),
          SizedBox(height: 16),

          // 群聊成员卡片
          _buildMembersCard(context),
          SizedBox(height: 16),

          // 聊天设置卡片
          _buildSettingsCard(context),
          SizedBox(height: 16),

          // 社区推荐卡片
          _buildRecommendationsCard(context),
        ],
      ),
    );
  }

  // 群聊名片卡片
  Widget _buildGroupProfileCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _handleGroupTap(currentGroup),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(currentGroup.avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentGroup.groupName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentGroup.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 构建群聊成员卡片
  Widget _buildMembersCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _handleViewMembers,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '社群成员',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      Text(
                        '查看${currentGroup.membersCount}名社区成员',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMembersGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersGrid() {
    final displayMembers = currentGroup.members.take(13).toList();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: 0.7,
      children: [
        ...displayMembers.map((member) => _buildMemberItem(
              avatarUrl: member.avatarUrl,
              username: member.name,
              onTap: () => _handleMemberTap(member),
            )),
        _buildSpecialItem(
          icon: Icons.person_add_alt_1,
          label: '邀请成员',
          color: Colors.blue,
          onTap: _inviteMember,
        ),
        _buildSpecialItem(
          icon: Icons.person_remove_alt_1,
          label: '移除成员',
          color: Colors.red,
          onTap: _removeMember,
        ),
      ],
    );
  }

  // 构建社区用户网格元素
  Widget _buildMemberItem(
      {required String avatarUrl,
      required String username,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(height: 6),
          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 构建特殊的网格元素
  Widget _buildSpecialItem(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 推荐社区卡片
  Widget _buildRecommendationsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                '推荐社区',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedGroups.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 0.8,
                  color: Colors.grey[300],
                ),
              ),
              itemBuilder: (context, index) =>
                  _buildRecommendationItem(recommendedGroups[index], context),
            ),
          ],
        ),
      ),
    );
  }

  // 推荐社区卡片元素
  Widget _buildRecommendationItem(GroupItem group, BuildContext context) {
    return InkWell(
      onTap: () => _handleGroupTap(group),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(currentGroup.avatarUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentGroup.groupName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentGroup.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // 聊天设计卡片
  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              thickness: 0.8,
              color: Colors.grey[300],
            ),
          ),
          itemCount: settings.length,
          itemBuilder: (context, index) => _buildSettingItem(settings[index]),
        ),
      ),
    );
  }

  // 单个设置项
  Widget _buildSettingItem(SettingItem setting) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          title: Text(setting.title),
          value: setting.value,
          onChanged: (value) => setState(() => setting.value = value),
          activeColor: CupertinoColors.activeBlue,
        );
      },
    );
  }

  void _handleGroupTap(GroupItem group) {
    // TODO: 实现社群名片的点击逻辑
  }

  void _handleViewMembers() {
    // final GroupItem groupItem = GroupItem(
    //   id: '1',
    //   groupName: 'TestGroup',
    //   avatarUrl: 'https://picsum.photos/200/200?random=2',
    //   description: '.......',
    //   members: [],
    //   membersCount: 0,
    // );
    // _generateMockData(groupItem);
    // // TODO: 查看成员列表
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => GroupMembersPage(group: groupItem)));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GroupMembersPage(
              group: GroupItem(
                id: '1',
                groupName: 'Flutter开发者',
                avatarUrl: '',
                description: 'Flutter开发交流群',
                membersCount: 100,
                members: _generateMockData(),
              ),
            )));
  }

  void _handleMemberTap(Member member) {
    // TODO: 实现点击成员的逻辑
  }

  void _inviteMember() {
    // TODO: 实现邀请成员逻辑
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => InviteMemberPage()));
  }

  void _removeMember() {
    // TODO: 实现移除成员逻辑
  }
}

// 自定义卡片组件
// 自定义卡片组件
class _InfoCard extends StatelessWidget {
  final double height;
  final Color color;
  final String title;

  const _InfoCard({
    required this.height,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '占位内容',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
