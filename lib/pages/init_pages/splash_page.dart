import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_state_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLonginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final auth = context.read<AuthStateProvider>();
    await auth.initialize();

    if (mounted) {
      context.go(auth.isLoggedInID >= 0 ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _checkLonginStatus() async {
    // TODO：实现登陆状态检查逻辑
    // 模拟检查延迟
    await Future.delayed(Duration(seconds: 2));

    bool isLoggedIn = await checkUserLoggedIn();

    if (isLoggedIn && mounted) {
      // Navigator.pushReplacementNamed(context, '/home');
      context.go('/home');
    } else if (mounted) {
      // Navigator.pushReplacementNamed(context, '/login');
      context.go('/login');
    }
  }

  Future<bool> checkUserLoggedIn() async {
    // 从本地存储读取登陆状态
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
