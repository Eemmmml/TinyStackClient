import 'package:flutter/material.dart';

// TODO: 优化主题加载时机造成的逻辑错误问题
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  // bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;

  // bool get isInitialized => _isInitialized;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
