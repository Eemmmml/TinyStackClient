import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinystack/pojo/user_login_pojo.dart';
import 'package:tinystack/provider/auth_state_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 用户名文本输入控制器
  final _usernameController = TextEditingController();

  // 密码文本输入控制器
  final _passwordController = TextEditingController();

  // 密码可见性
  bool _obscurePassword = true;

  // 加载状态
  bool _isLoading = false;

  final dio = Dio();

  final logger = Logger();

  // TODO: 完善登录逻辑
  Future<void> _login() async {
    setState(() {
      _isLoading = !_isLoading;
    });
    // 调用服务端 API 进行用户登录
    final username = _usernameController.text;
    final password = _passwordController.text;

    Map<String, String> queryParams = {
      'username': username,
      'password': password,
    };

    final response = await dio.get('http://10.198.190.235:8080/user/signin',
        queryParameters: queryParams);

    if (response.statusCode == 200) {
      logger.d('用户登录请求成功');

      logger.d('相应内容 ${response.data}');
      final responseData = UserLoginPojo.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      final bool result;
      final int userID;
      if (responseData.data != null && responseData.data!.token.isNotEmpty) {
        // TODO: 获取用户 ID
        userID = responseData.data!.userID;
        await prefs.setInt('isLoggedInID', userID);
        logger.d('用户登陆成功, 用户 ID: $userID');
        result = true;
      } else {
        await prefs.setInt('isLoggedInID', -1);
        logger.d('用户登录失败，用户名或密码错误');
        userID = -1;
        result = false;
        _showErrorSnackBar('用户名或密码错误');
      }

      if (mounted && result) {
        final authProvider =
            Provider.of<AuthStateProvider>(context, listen: false);
        authProvider.login(userID);
        // Navigator.pushReplacementNamed(context, '/home');
        authProvider.setRedirectPath('/home');
        logger.d('跳转页面到应用首页');
        context.go('/home');
      }

      setState(() {
        _isLoading = !_isLoading;
      });
    } else {
      logger.d('用户登录请求失败');

      setState(() {
        _isLoading = !_isLoading;
      });

      _showErrorSnackBar('登录失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        'assets/login_background/login_background_3.jpg'),
                    fit: BoxFit.cover)),
          ),

          // 内容区域增加滚动
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 80),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 50,
                        child: _buildUsernameField(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        child: _buildPasswordField(),
                      ),
                      const SizedBox(height: 25),
                      _buildLoginButton(),
                      _buildHelperLinks(),
                    ],
                  ),
                )),
          ),
        ],
      ),
    ));
  }

  // 构建登录页面头部，内容包含项目 Logo 项目名称
  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          child: Image(image: AssetImage('assets/logo.png')),
        ),
        const SizedBox(height: 20),
        const Text(
          '欢迎登录小栈',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    );
  }

  // TODO: 对于用户名输入内容的字符集和字符数需要进一步的精确控制
  // 构建用户名输入框
  Widget _buildUsernameField() {
    return TextFormField(
        controller: _usernameController,
        keyboardType: TextInputType.text,
        maxLines: 1,
        decoration: const InputDecoration(
          labelText: '用户名',
          prefixIcon: Icon(Icons.people),
        ),
        validator: (username) =>
            (username == null || username.isEmpty) ? '请输入邮箱' : null);
  }

  // TODO: 对用密码的输入内容的字符集和字符数需要进一步的精确控制
  // 构建密码输入框
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: "密码",
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() {
              _obscurePassword = !_obscurePassword;
            }),
          )),
      validator: (password) {
        if (password == null || password.isEmpty) return '请输入密码';
        if (password.length < 6) {
          return '密码不少于6位';
        }
        return null;
      },
    );
  }

  // 构建登录按钮
  Widget _buildLoginButton() {
    return ElevatedButton(
      // 禁用加载中的按钮
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('登录'),
    );
  }

  Widget _buildHelperLinks() {
    final authProvider = Provider.of<AuthStateProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            // TODO: 跳转注册页面
            authProvider.setRedirectPath('/signup');
            context.go('/signup');
          },
          child: const Text('立即注册'),
        ),
        TextButton(
          onPressed: () {
            // TODO: 跳转忘记密码页面
          },
          child: const Text('忘记密码?'),
        )
      ],
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
