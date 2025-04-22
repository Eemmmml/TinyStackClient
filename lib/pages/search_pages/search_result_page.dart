import 'package:flutter/material.dart';

import '../../entity/search_result_item.dart';
import 'article_search_results_page.dart';
import 'comprehensive_search_results_page.dart';
import 'user_search_results_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String initialKeyword;

  const SearchResultsPage({super.key, required this.initialKeyword});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // 搜索栏文字输入控制器
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialKeyword;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              // TODO: 实现按钮点击逻辑
              Navigator.of(context).pop();
            },
          ),
          title: Container(
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: '搜索内容...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors.grey[600], size: 20),
                              onPressed: () {
                                _searchController.clear();
                                // TODO: 添加清除搜索框内容后的业务逻辑
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: 实现搜索按钮点击逻辑
              },
              child: const Text(
                '搜索',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '综合'),
              Tab(text: '用户'),
              Tab(text: '图文'),
              Tab(text: '直播'),
            ],
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.pinkAccent,
          ),
        ),
        body: TabBarView(
          children: [
            ComprehensiveSearchResultsPage(searchResults: mockSearchResults),
            UserSearchResultsPage(),
            ArticleSearchResultsPage(),
            Container(
              color: Colors.grey[200],
              child: Center(
                child: Text('内容'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
