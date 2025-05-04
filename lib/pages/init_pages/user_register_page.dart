import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinystack/pojo/user_register_pojo.dart';
import 'package:tinystack/pojo/user_sign_up_pojo.dart';
import 'package:tinystack/provider/auth_state_provider.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final dio = Dio();

  final logger = Logger();

  final _formKey = GlobalKey<FormState>();

  // 用户名输入控制器
  final _usernameController = TextEditingController();

  // 密码输入控制器
  final _passwordController = TextEditingController();

  // 确认密码控制器
  final _confirmPasswordController = TextEditingController();

  // 密码是否可见
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('用户注册')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 用户名输入
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: '用户名',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]{4,20}$').hasMatch(value)) {
                      return '用户名为 4-20 位字母、数字或下滑线';
                    }
                    return null;
                  },
                ),
                _buildHintText('4-20位字母、数字或下滑线'),
                const SizedBox(height: 16),

                // 密码输入
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 8) {
                      return '密码至少8位';
                    }
                    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return '需要包含大写字母和数字';
                    }
                    return null;
                  },
                ),
                _buildHintText('至少8位，包含大写字母和数字'),
                const SizedBox(height: 16),

                // 确认密码
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),
                _buildHintText('请再次确认密码'),
                const SizedBox(height: 12),

                // 注册按钮
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: const Text('注册'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserRegisterPojo(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Map<String, dynamic> json = newUser.toJson();

      logger.d('尝试注册用户：${newUser.username}');

      // 处理 Server 端的用户注册逻辑
      final response =
          await dio.post('http://10.198.190.235:8080/user/signup', data: json);
      final responseData = UserSignUpPojo.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      final int userID;
      if (responseData.data > 0) {
        // TODO: 获取用户 ID
        userID = 0;
        await prefs.setInt('isLoggedInID', userID);
        logger.d('用户注册并登陆成功');
      } else {
        userID = -1;
        await prefs.setInt('isLoggedInID', userID);
        logger.d('用户注册失败：${responseData.msg}');
        _showErrorSnackBar('用户注册失败：${responseData.msg}');
      }

      logger.d('用户注册成功 username: ${newUser.username}');
      if (mounted) {
        final authProvider =
            Provider.of<AuthStateProvider>(context, listen: false);
        authProvider.login(userID);
        authProvider.setRedirectPath('/home');
        context.go('/home');
      }
    }
  }

  Widget _buildHintText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 4.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 显示错误提示
  void _showErrorSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            // TODO: 实现点击逻辑
          },
        ),
      ),
    );
  }
}
