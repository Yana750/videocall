import 'package:flutter/material.dart';
import '../messages/chat_bubble.dart';
import '../messages/message.dart';
import '../services/jitsi_service.dart';
import '../services/supabase_service.dart';


class ChannelChatScreen extends StatefulWidget {
  final String channelId;
  const ChannelChatScreen({super.key, required this.channelId});

  @override
  _ChannelChatScreenState createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Чат канала"),
        actions: [
          IconButton(
            onPressed: () async {
              final String? userId = supabaseService.currenUserId; // Получаем ID пользователя
              final String? userEmail = await supabaseService.getUserEmail(); // Получаем email пользователя

              // Проверяем, авторизован ли пользователь
              if (userId != null && userEmail != null) {
                // Если авторизован, запускаем видеозвонок
                JitsiService().joinMeeting(); // Используем публичный метод
              } else {
                // Если не авторизован, выводим ошибку
                print("Ошибка: Пользователь не авторизован");
              }
            },
            icon: Icon(Icons.video_camera_back_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Подключаем ChatBubble вместо ListTile
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: supabaseService.getMessages(widget.channelId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                List<Message> messages = snapshot.data!.map((msg) =>
                    Message.fromJson(msg, supabaseService.currentUserId ?? "")
                ).toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: "Сообщение"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      supabaseService.sendMessage(widget.channelId, _controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}