import 'package:flutter/material.dart';

import '../../entity/user_basic_info.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 用户名输入控制器
  final TextEditingController _usernameController = TextEditingController();

  // 个人简介输入控制器
  final TextEditingController _bioController = TextEditingController();

  // 默认的头像
  static const String defaultAvatarUrl = 'assets/user_info/user_avatar2.jpg';
  String _avatarUrl = '';
  UserBasicInfo myUserBasicInfo = UserBasicInfo.myUserBasicInfo;

  @override
  void initState() {
    super.initState();
    // TODO: 初始化当前用户数据
    // 当前的用户名
    _usernameController.text = myUserBasicInfo.username;
    // 当前的个人简介
    _bioController.text = myUserBasicInfo.description;
    // 当前的用户头像
    _avatarUrl = myUserBasicInfo.avatarImageUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('编辑资料'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // TODO: 实现修改后的数据的同步逻辑
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildUsernameSection(),
            const SizedBox(height: 16),
            _buildBioSection(),
          ],
        ),
      ),
    );
  }

  // 构建头像部分
  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: () {
        // TODO: 实现头像修改的逻辑
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 64,
            backgroundImage: myUserBasicInfo.avatarImageUrl.isNotEmpty
                ? NetworkImage(myUserBasicInfo.avatarImageUrl)
                : const AssetImage(defaultAvatarUrl) as ImageProvider,
            child: myUserBasicInfo.avatarImageUrl.isEmpty
                ? const Icon(Icons.person, size: 64)
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // 构建用户名部分
  Widget _buildUsernameSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Expanded(
              flex: 2,
              child: Text('昵称'),
            ),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '请输入修改后的昵称',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLength: 20,
                buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建个人简介部分
  Widget _buildBioSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('个人简介'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '介绍一下自己吧...',
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 4,
              maxLength: 200,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
            ),
          ],
        ),
      ),
    );
  }
}
