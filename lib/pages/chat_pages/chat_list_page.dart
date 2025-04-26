import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../entity/chat_item.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // 聊天数据实体
  List<ChatItem> myChatItems = ChatItem.chatItems.toList();

  @override
  Widget build(BuildContext context) {
    final visibleChats = myChatItems.where((chat) => !chat.isHidden).toList()
      ..sort((a, b) {
        if (a.isPinned && b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('社群聊天'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: 完善点击业务逻辑
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 完善点击业务逻辑
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: visibleChats.length,
        itemBuilder: (context, index) {
          final chat = visibleChats[index];
          return Slidable(
            endActionPane: ActionPane(
              extentRatio: 0.75,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _toggleChatPin(chat),
                  backgroundColor: Colors.blue,
                  icon:
                      chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  label: chat.isPinned ? '取消置顶' : '置顶聊天',
                  flex: 2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                SlidableAction(
                  onPressed: (context) => _toggleChatHide(chat),
                  backgroundColor: Colors.grey,
                  icon: chat.isHidden ? Icons.visibility : Icons.visibility_off,
                  label: chat.isHidden ? '取消隐藏' : '隐藏聊天',
                  flex: 2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                SlidableAction(
                  onPressed: (context) => _deleteChat(chat),
                  backgroundColor: Colors.red,
                  icon: Icons.delete_forever,
                  label: '删除',
                  flex: 2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ],
            ),
            child: ChatListItem(item: chat),
          );
        },
      ),
    );
  }

  // 新增构建滑动按钮方法
//   Widget _buildSlidableAction(BuildContext context ,{
//     required IconData icon,
//     required String label,
//     required Color color,
//     required Function(BuildContext) onPressed,
// }) {
//     return SlidableAction(
//       onPressed: onPressed,
//       backgroundColor: color,
//       flex: 2,
//       label: label,
//       autoClose: true,
//       ch
//     );
//   }

  void _toggleChatPin(ChatItem chat) {
    // TODO: 实现切换聊天置顶状态
    setState(() {
      final index = myChatItems.indexWhere((e) => e.id == chat.id);
      myChatItems[index] = chat.copyWith(isPinned: !chat.isPinned);
    });
  }

  void _toggleChatHide(ChatItem chat) {
    // TODO: 实现聊天隐藏状态切换
    setState(() {
      final index = myChatItems.indexWhere((e) => e.id == chat.id);
      myChatItems[index] = chat.copyWith(isHidden: !chat.isHidden);
    });
  }

  void _deleteChat(ChatItem chat) {
    // TODO: 实现删除聊天逻辑
    setState(() {
      myChatItems.removeWhere((e) => e.id == chat.id);
    });
  }
}

class ChatListItem extends StatelessWidget {
  final ChatItem item;

  const ChatListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.isPinned ? Colors.grey[200] : null,
      child: ListTile(
        leading: CircleAvatar(
          // TODO: 将图片获取改为从网络中获取
          // backgroundImage: NetworkImage(url);
          backgroundImage: NetworkImage(item.avatarUrl),
          radius: 25,
        ),
        title: Row(
          children: [
            Text(item.name),
            if (item.isGroup)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.group, size: 16),
              ),
          ],
        ),
        subtitle: Text(
          item.lastMessage,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedTime,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (item.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          // TODO: 实现点击跳转聊天页面
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatPage(
                  currentChat: ChatItem(
                      id: '1',
                      name: '群聊1',
                      isGroup: true,
                      avatarUrl: 'https://picsum.photos/200/200?random=2',
                      lastMessage: '',
                      timestamp: DateTime.now(),
                      unreadCount: 0))));
        },
      ),
    );
  }
}
