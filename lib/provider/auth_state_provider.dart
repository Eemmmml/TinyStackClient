import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStateProvider extends ChangeNotifier {
  int _isLoggedInID = -1;
  String? _redirectPath;
  bool _initialized = false;

  int get isLoggedInID => _isLoggedInID;

  String? get redirectPath => _redirectPath;

  bool get initialized => _initialized;

  final logger = Logger();

  Future<void> initialize() async {
    await _loadLonginStatus();
    _initialized = true;
    notifyListeners();
  }

  // 加载登陆状态
  Future<void> _loadLonginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedInID = prefs.getInt('isLoggedInID') ?? -1;
    logger.d('Loaded Login Status: $_isLoggedInID');
    // notifyListeners();
  }

  // 登陆
  Future<void> login(int userID) async {
    // TODO: 与服务器交互，进一步完善登陆逻辑
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isLoggedInID', userID);
    _isLoggedInID = userID;
    notifyListeners();
  }

  // 登出
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    _isLoggedInID = -1;
    notifyListeners();
  }

  // 设置重定向路径
  void setRedirectPath(String? path) {
    _redirectPath = path;
    notifyListeners();
  }
}
