import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tinystack/main.dart';
import 'package:tinystack/pages/init_pages/login_page.dart';
import 'package:tinystack/pages/user_pages/profile_page.dart';
import 'package:tinystack/pages/user_pages/user_register_page.dart';

import '../pages/init_pages/splash_page.dart';
import '../provider/auth_state_provider.dart';

final logger = Logger();

final router = GoRouter(
  routes: [
    GoRoute(path: '/', redirect: (_, __) => '/splash'),
    GoRoute(
        path: '/splash',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: SplashPage(),
          );
        }),
    GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: LoginPage(),
          );
        }),
    GoRoute(
        path: '/signup',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: UserRegisterPage(),
          );
        }),
    GoRoute(
        path: '/home',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: HomePage(title: 'TinyStack'),
          );
        }),
    GoRoute(
        path: '/profile',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: ProfilePage(),
          );
        }),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final auth = Provider.of<AuthStateProvider>(context, listen: false);
    final isLoggedIn = auth.isLoggedIn;
    final isLoggingIn = state.path == '/login';
    // 避免在初始化完成前处理重定向
    if (!auth.initialized) return null;

    if (auth.redirectPath != null && auth.redirectPath != '/login') {
      logger.d('重定向 Path：${auth.redirectPath}');
      logger.d('重定向到应用登录页');
      return auth.redirectPath;
    }

    // 未登录且当前不是登录页
    if (!isLoggedIn && !isLoggingIn) {
      logger.d('重定向 Path：${auth.redirectPath}');
      logger.d('重定向到应用登录页');
      auth.setRedirectPath(state.path);
      return '/login';
    }

    // 已登录但是当前是登录页
    if (isLoggedIn && isLoggingIn) {
      logger.d('重定向 Path：${auth.redirectPath}');
      logger.d('重定向到应用首页');
      auth.setRedirectPath(state.path);
      return auth.redirectPath ?? '/home';
    }

    // 无需重定向
    return null;
  },
);
