import 'package:flutter/material.dart';

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

  // TODO: 完善登录逻辑
  Future<void> _login() async {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/login_background/login_background_3.jpg'),
                  fit: BoxFit.cover)),
        ),
        Padding(
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
            ))
      ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            // TODO: 跳转注册页面
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
}
