import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/pojo/search_result_pojo/search_history_pojo.dart';
import 'package:tinystack/pojo/search_result_pojo/search_recommendation_pojo.dart';
import 'package:tinystack/pojo/search_result_pojo/sync_search_history_pojo.dart';
import 'package:tinystack/provider/auth_state_provider.dart';

import 'search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 日志工具
  final Logger logger = Logger();

  // 网络请求工具
  final Dio dio = Dio();

  // 搜索文本输入控制器
  final TextEditingController _controller = TextEditingController();

  // 搜索建议的条数
  final _suggestionNum = 6;

  // 历史搜索内容
  // TODO: 从后段服务获取历史搜索内容
  List<String>? _searchHistory;

  // 热门搜索内容
  // TODO: 从后端服务获取热门搜索内容
  List<String>? _hotSearch;

  // 联想搜索建议
  List<String>? _suggestions = [];

  // 数据加载状态
  bool _isLoadingSuggestions = false;

  // 初始数据是否已经加载
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller.clear();
    _loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 加载初始数据
  void _loadInitialData() async {
    if (_initialDataLoaded) return;
    final history = await _fetchSearchHistory();
    final hot = await _fetchHotSearch();
    setState(() {
      _searchHistory = history;
      _hotSearch = hot;
      _initialDataLoaded = true;
    });
  }

  // 获取搜索历史
  Future<List<String>> _fetchSearchHistory() async {
    final provider = Provider.of<AuthStateProvider>(context, listen: false);
    final userId = provider.isLoggedInID;
    final response = await dio.get('${DioConfig.severUrl}/content/search/history', queryParameters: {
      'userId': userId,
    });

    if (response.statusCode == 200) {
      logger.d('搜索历史获取请求成功');
      final result = SearchHistoryListPojo.fromJson(response.data);
      if (result.code == 1) {
        final tempData = result.data;
        logger.d('搜索历史数据获取成功: $tempData');
        final List<String> data = [];
        for (var d in tempData) {
          data.add(d['keyword'] as String);
        }
        return data;
      } else {
        logger.e('搜索历史数据获取失败: ${result.msg}');
        return [];
      }
    } else {
      logger.e('搜索历史获取请求成功');
      return [];
    }
  }

  // 获取热门搜索
  Future<List<String>> _fetchHotSearch() async {
    // await Future.delayed(const Duration(seconds: 1));
    // return List.generate(6, (index) => 'Mock热门${index + 1}');
    final response = await dio.get('${DioConfig.severUrl}/content/search/hot', queryParameters: {"count": _suggestionNum});
    if (response.statusCode == 200) {
      logger.d('获取热门搜索请求成功');
      final data = SearchRecommendationPojo.fromJson(response.data);
      if (data.code == 1) {
        logger.d('热门搜索获取成功');
        return data.data;
      } else {
        logger.e('热门建议获取失败');
        return [];
      }
    } else {
      logger.e('获取热门搜索内容请求失败');
      return [];
    }
  }

  // 获取联想搜索建议
  Future<List<String>> _fetchSuggestions() async {
    // await Future.delayed(const Duration(seconds: 1));
    // return List.generate(_suggestionNum, (index) => 'Mock建议${index + 1}');
    final keyword = _controller.text;
    final response = await dio.get('${DioConfig.severUrl}/content/search/recommendation', queryParameters: {"keyword": keyword});
    if (response.statusCode == 200) {
      logger.d('获取搜索建议请求成功');
      final data = SearchRecommendationPojo.fromJson(response.data);
      if (data.code == 1) {
        logger.d('搜索建议获取成功');
        return data.data;
      } else {
        logger.e('搜索建议获取失败');
        return [];
      }
    } else {
      logger.e('获取搜索建议请求失败');
      return [];
    }
  }

  void _performSearch(String keyword) async {
    if (keyword.isEmpty) return;

    FocusScope.of(context).unfocus();

    final provider = Provider.of<AuthStateProvider>(context, listen: false);
    // 开始向后台数据库同步新的搜索历史数据
    await _uploadHistory(keyword, provider.isLoggedInID);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SearchResultsPage(initialKeyword: keyword)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  // TODO: 可以尝试实现像 B 站中类似的默认推荐搜索内容
                  hintText: '输入搜索内容',
                  border: InputBorder.none,
                ),
                onChanged: (value) async {
                  if (value.isEmpty) {
                    setState(() {
                      _suggestions = [];
                    });
                    return;
                  }

                  setState(() {
                    _isLoadingSuggestions = true;
                  });
                  final suggestions = await _fetchSuggestions();
                  setState(() {
                    _suggestions = suggestions;
                    _isLoadingSuggestions = false;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _performSearch(_controller.text),
            ),
          ],
        ),
      ),
      // body: _buildBody(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollStartNotification) {
              FocusScope.of(context).unfocus();
            }
            return false;
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_controller.text.isEmpty) ...[
          _buildSectionTitle('热门搜索'),
          _buildHotSearchList(),
          const Divider(),
          _buildSectionTitle('搜索历史'),
          _buildHistoryList(),
        ] else ...[
          _buildSectionTitle('搜索建议'),
          _buildSuggestionList(),
        ]
      ],
    );
  }

  // 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        // child: CircularProgressIndicator(),
        child: Image.asset('assets/loading1.gif',
            width: 50, height: 50, fit: BoxFit.contain),
      ),
    );
  }

  // 构建分部的标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // 构建搜索历史部分
  Widget _buildHistoryList() {
    if (_searchHistory == null) return _buildLoadingIndicator();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _searchHistory!
          .map((history) => GestureDetector(
                onTap: () => _navigateToResult(history),
                // onTap: () {
                //   // TODO: 处理点击搜索事件
                //   Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) =>
                //           SearchResultsPage(initialKeyword: '西瓜')));
                // },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(history, style: const TextStyle(fontSize: 14))
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // 构建搜索建议部分
  Widget _buildSuggestionList() {
    if (_isLoadingSuggestions) return _buildLoadingIndicator();
    return Column(
      children: _suggestions!
          .map((suggestion) => ListTile(
                leading: const Icon(Icons.search, size: 20),
                title: Text(suggestion),
                // onTap: () {
                //   // TODO: 填充建议内容并搜索
                //   Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) =>
                //           SearchResultsPage(initialKeyword: _controller.text)));
                // },
        onTap: () async {
                  final provider = Provider.of<AuthStateProvider>(context, listen: false);
                  _uploadHistory(suggestion, provider.isLoggedInID);
                  _navigateToResult(suggestion);
        },
              ))
          .toList(),
    );
  }

  // 构建热门搜索部分
  Widget _buildHotSearchList() {
    if (_hotSearch == null) return _buildLoadingIndicator();
    return Column(
      children: _hotSearch!
          .map((hotElement) => ListTile(
                leading: const Icon(Icons.whatshot, size: 20),
                title: Text(hotElement),
                // onTap: () {
                //   // TODO: 填充搜索内容并搜索
                //   Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) =>
                //           SearchResultsPage(initialKeyword: '西瓜')));
                // },
                onTap: () => _navigateToResult(hotElement),
              ))
          .toList(),
    );
  }

  Future<void> _uploadHistory(String keyword, int userId) async {
    final response = await dio.post('${DioConfig.severUrl}/content/search/history/new', queryParameters: {"keyword": keyword, "userId": userId});
    if (response.statusCode == 200) {
      logger.d('开始向服务器同步新的搜索历史数据: userId: $userId keyword: $keyword');
      if (response.statusCode == 200) {
        final result = SyncSearchHistoryPojo.fromJson(response.data);
        if (result.data) {
          logger.d('向服务器同步新的搜索历史数据成功');
        } else {
          logger.e('向服务器同步新的搜索历史数据失败');
        }
      }
    } else {
      logger.d('向服务器同步新的搜索历史数据失败: userId: $userId keyword: $keyword');
    }
  }

  // 跳转到搜索结果页面
  void _navigateToResult(String keyword) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SearchResultsPage(initialKeyword: keyword)));
  }

// // 构建热门搜索部分
// Widget _buildHotSearchList() {
//   return Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     children: _hotSearch
//         .map((hotElement) => GestureDetector(
//               onTap: () {
//                 // TODO: 处理点击搜索事件
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.whatshot, size: 16, color: Colors.red),
//                     const SizedBox(width: 4),
//                     Text(hotElement, style: const TextStyle(fontSize: 14))
//                   ],
//                 ),
//               ),
//             ))
//         .toList(),
//   );
// }
}
