import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tinystack/provider/audio_player_provider.dart';
import 'package:tinystack/provider/auth_state_provider.dart';

import 'pages/chat_pages/chat_list_page.dart';
import 'pages/init_pages/login_page.dart';
import 'pages/init_pages/splash_page.dart';
import 'pages/main_pages/main_page.dart';
import 'pages/user_pages/profile_page.dart';
import 'provider/theme_provider.dart';
import 'configs/router_config.dart';



void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintLayerBordersEnabled = true;

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // 定义路由监听器
  // runApp(const Home());
  // runApp(
  //   ChangeNotifierProvider(
  //     create: (_) => ThemeProvider(),
  //     child: const Home(),
  //   ),
  // );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioPlayerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthStateProvider(),
        ),
      ],
      child: const Home(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'TinyStack',
      theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)))),
      darkTheme: ThemeData.dark(),
      // home: HomePage(title: 'Tiny Stack'),
      // home: SplashPage(),
      themeMode: context.watch<ThemeProvider>().themeMode,
      // home: LoginPage(),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // routes: {
      //   '/login': (context) => LoginPage(),
      //   '/home': (context) => HomePage(title: 'TinyStack'),
      // },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // TODO: 添加各个页面的实例
  final List<Widget> _pages = [MainPage(), ChatListPage(), ProfilePage()];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      // body: IndexedStack(
      //   index: _currentIndex,
      //   children: _pages,
      // ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) => setState(() {
          _currentIndex = index;
        }),
        children: [
          MainPage(key: _pageKeys[0]),
          ChatListPage(key: _pageKeys[1]),
          ProfilePage(key: _pageKeys[2]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '社区'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的')
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // 为每个页面创建唯一的 GlobalKey
  final List<GlobalKey<State<StatefulWidget>>> _pageKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return MainPage(key: _pageKeys[0]);
      case 1:
        return ChatListPage(key: _pageKeys[1]);
      case 2:
        return ProfilePage(key: _pageKeys[2]);
      default:
        return Container();
    }
  }
}
