import 'package:flutter/material.dart';
import '../messages/chat_bubble.dart';
import '../messages/message.dart';
import '../services/jitsi_service.dart';
import '../services/supabase_service.dart';
import 'VideoCallScreen.dart';


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
            icon: Icon(Icons.video_call, color: Colors.blueGrey, size: 30),
            onPressed: () async {
              String meetingUrl = await jitsiService.createMeeting(widget.channelId);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JoinMeetingScreen(meetingUrl: meetingUrl)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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