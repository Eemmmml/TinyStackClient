import 'package:flutter/material.dart';

import 'search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  // 历史搜索内容
  // TODO: 从后段服务获取历史搜索内容
  final List<String> _searchHistory = [
    '搜索历史1',
    '搜索历史2',
    '搜索历史3',
    '搜索历史4',
    '搜索历史5',
    '搜索历史6',
  ];

  // 热门搜索内容
  // TODO: 从后端服务获取热门搜索内容
  final List<String> _hotSearch = [
    '热门搜索1',
    '热门搜索2',
    '热门搜索3',
    '热门搜索4',
    '热门搜索5',
    '热门搜索6',
  ];

  // 搜索建议的数目
  final _suggestionNum = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 获取搜索建议
  // TODO: 从后段服务获取搜索建议
  List<String> get _suggestions {
    if (_controller.text.isEmpty) return [];
    return List.generate(
        _suggestionNum, (index) => '${_controller.text}建议${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            // TODO: 可以尝试实现像 B 站中类似的默认推荐搜索内容
            hintText: '输入搜索内容',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() {
            // 实现文本区域内容发生变化时的逻辑
          }),
        ),
      ),
      body: _buildBody(),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _searchHistory
          .map((history) => GestureDetector(
                onTap: () {
                  // TODO: 处理点击搜索事件
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SearchResultsPage(initialKeyword: '西瓜')));
                },
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
    return Column(
      children: _suggestions
          .map((suggestion) => ListTile(
                leading: const Icon(Icons.search, size: 20),
                title: Text(suggestion),
                onTap: () {
                  // TODO: 填充建议内容并搜索
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SearchResultsPage(initialKeyword: '西瓜')));
                },
              ))
          .toList(),
    );
  }

  // 构建热门搜索部分
  Widget _buildHotSearchList() {
    return Column(
      children: _hotSearch
          .map((hotElement) => ListTile(
                leading: const Icon(Icons.whatshot, size: 20),
                title: Text(hotElement),
                onTap: () {
                  // TODO: 填充搜索内容并搜索
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SearchResultsPage(initialKeyword: '西瓜')));
                },
              ))
          .toList(),
    );
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
