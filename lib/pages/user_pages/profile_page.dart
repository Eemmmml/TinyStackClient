import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinystack/pojo/user_profile_info_pojo.dart';
import 'package:logger/logger.dart';
import 'package:tinystack/provider/auth_state_provider.dart';
import 'package:tinystack/utils/data_format_utils.dart';
import 'package:dio/dio.dart';

import '../../entity/user_basic_info.dart';
import '../../provider/theme_provider.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver{
  // 获取个人用户数据
  // final UserBasicInfo myUserBasicInfo = UserBasicInfo.myUserBasicInfo;
  // 用户数据
  UserBasicInfo? _userInfo;

  // 页面加载状态
  bool _isLoading = false;

  // 页面加载错误信息
  String _errorMessage = '';

  final dio = Dio();

  final logger = Logger();

  @override
  void initState() {
    super.initState();
    // 初始化时加载用户数据
    _loadUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面重新显示时加载用户数据
    // if (ModalRoute.of(context)?.settings.arguments == 'forceRefresh') {
    //   _loadUserInfo();
    // }
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 模拟网络请求，实际开发中替换为真实API调用
      final UserBasicInfo? userInfo;
      final authProvider = Provider.of<AuthStateProvider>(context, listen: false);
      final userID = authProvider.isLoggedInID;

      logger.d('尝试向服务器请求用户主页数据, 用户 ID: $userID');
      final response = await dio.get('http://10.198.190.235:8080/user/info/$userID');

      if (response.statusCode == 200) {
        final responseData = UserProfileInfoPojo.fromJson(response.data);

        if (responseData.code == 1) {
          logger.d('用户数据获取成功');
          userInfo = responseData.data;
          logger.d('用户数据: ${userInfo.toString()}');
          if (mounted) {
            setState(() {
              _userInfo = userInfo;
              _isLoading = false;
            });
          }
        } else {
          logger.d('用户数据获取失败');
          userInfo = null;
          if (mounted) {
            setState(() {
              _userInfo = userInfo;
              _isLoading = false;
            });
          }
        }
      } else {
        userInfo = null;
        setState(() {
          _isLoading = false;
          _errorMessage = '请求失败';
        });
      }


      if (userInfo == null) {
        throw Exception('Failed to load user data');
      }

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 主题数据控制器提供者
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

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
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              // TODO: 实现亮色主题和暗色主体切换的功能
              // TODO: 添加对于APP状态的持久化存储
              themeProvider
                  .toggleTheme((themeProvider.themeMode != ThemeMode.dark));
            },
          ),
          IconButton(
            icon: const Icon(Icons.face),
            onPressed: () {
              // TODO: 实现跳转个人信息编辑页面
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileEditPage()));
            },
          ),
        ],
      ),
      body: _buildPageContent(themeProvider),
    );
  }

  Widget _buildPageContent(ThemeProvider themeProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_errorMessage'),
            ElevatedButton(
              onPressed: () async => await _loadUserInfo(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_userInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('用户数据获取失败'),
            ElevatedButton(
              onPressed: () async => await _loadUserInfo(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserInfo,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserinfoSection(_userInfo!),
            _buildStatsSection(_userInfo!),
            _buildFunctionListSection(_userInfo!),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // 构建用户信息区块
  Widget _buildUserinfoSection(UserBasicInfo userInfo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 用户头像
          CachedNetworkImage(
            imageUrl: userInfo.avatarImageUrl,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 40,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(20),
              child: const CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 40,
              child: Icon(Icons.error, size: 40),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo.username,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  userInfo.description,
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
  Widget _buildStatsSection(UserBasicInfo userInfo) {
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
          _buildStatsItem(DataFormatUtils.formatNumber(userInfo.interests), '关注'),
          _buildStatsItem(DataFormatUtils.formatNumber(userInfo.compositions), '作品'),
          _buildStatsItem(DataFormatUtils.formatNumber(userInfo.fans), '粉丝'),
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
  Widget _buildFunctionListSection(UserBasicInfo userInfo) {
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

  Widget _buildLogoutButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: () async {
            // 登出确认对话框
            bool confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('确认退出'),
                content: const Text('您确定要退出吗 ？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );

            if (confirm) {
              // 执行登出操作
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              // 跳转到登陆页
              if (mounted) {
                final authProvider =
                    Provider.of<AuthStateProvider>(context, listen: false);
                authProvider.logout();
                authProvider.setRedirectPath('/login');
                context.go('/login');
              }
            }
          },
          child: const Text(
            '退出登录',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
