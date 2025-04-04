import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 实现具体功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              // TODO: 实现具体功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.face),
            onPressed: () {
              // TODO: 实现具体功能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TODO: 添加元素
            _buildUserinfoSection(),
            _buildStatsSection(),
            _buildFunctionListSection(),
          ],
        ),
      ),
    );
  }

  // 构建用户信息区块
  Widget _buildUserinfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户头像
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/user_info/user_avatar.jpg'),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户名',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '个人简介',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 构建数据统计区块
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(
        color: Colors.grey[300]!,
        width: 1,
      ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 添加元素
          _buildStatsItem('21', '关注'),
          _buildStatsItem('500', '作品'),
          _buildStatsItem('1w', '粉丝'),
        ],
      ),
    );
  }

  // 构建数据统计区块的具体元素
  Widget _buildStatsItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        )
      ],
    );
  }

  // 构建功能列表区块
  Widget _buildFunctionListSection() {
    final List<Map<String, dynamic>> functions = [
      {'icon': Icons.favorite, 'title': '我的收藏'},
      {'icon': Icons.history, 'title': '浏览历史'},
      {'icon': Icons.download, 'title': '离线缓存'},
      {'icon': Icons.wallet, 'title': '我的钱包'},
      {'icon': Icons.help_center, 'title': '帮助中心'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: functions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(functions[index]['icon']),
          title: Text(functions[index]['title']),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 实现点击功能图标处理功能
          },
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }
}
