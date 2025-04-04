import 'package:flutter/material.dart';

import '../entity/chat_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 聊天数据实体
  List<ChatItem> myChatItems = ChatItem.chatItems;

  @override
  Widget build(BuildContext context) {
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
        itemCount: myChatItems.length,
        itemBuilder: (context, index) {
          final item = myChatItems[index];
          return ChatListItem(item: item);
        },
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatItem item;

  const ChatListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        // TODO: 将图片获取改为从网络中获取
        // backgroundImage: NetworkImage(url);
        backgroundImage: AssetImage(item.avatarUrl),
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
              item.time,
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
      },
    );
  }
}
