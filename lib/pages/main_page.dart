import 'package:flutter/material.dart';

import 'search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/user_info/user_avatar.jpg'),
              radius: 16,
            ),
            onPressed: () {
              // 点击头像后出发实际逻辑
            },
          ),
          // title: TextFormField(
          //   decoration: InputDecoration(
          //       hintText: '搜索',
          //       filled: true,
          //       fillColor: Colors.grey[200],
          //       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(20),
          //         borderSide: BorderSide.none,
          //       ),
          //       enabledBorder: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(20),
          //         borderSide: BorderSide.none,
          //       ),
          //       focusedBorder: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(20),
          //         borderSide: BorderSide.none,
          //       ),
          //       suffixIcon: IconButton(
          //         icon: Icon(Icons.search, size: 20),
          //         onPressed: () {
          //           // TODO: 实现具体的搜索逻辑
          //         },
          //       )),
          //   readOnly: false,
          // ),
          title: InkWell(
            // TODO: 这里的导航逻辑用 Deep Link 进行更改进行更加统一的管理
            // onTap: () => Navigator.pushNamed(context, '/search'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SearchPage())),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('搜索', style: TextStyle(color: Colors.grey))
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.live_tv),
              onPressed: () {
                // 实现具体的点击功能
                print('点击搜索');
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // 实现具体的点击功能
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: '推荐'),
              Tab(text: '直播'),
              Tab(text: '追番'),
              Tab(text: '影视'),
            ],
            // 指示器颜色
            indicatorColor: Colors.blue,
            // 选中标签颜色
            labelColor: Colors.blue,
            // 未选中标签颜色
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(
          children: [
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Text('推荐'),
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Text('直播'),
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Text('追番'),
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Text('影视'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
