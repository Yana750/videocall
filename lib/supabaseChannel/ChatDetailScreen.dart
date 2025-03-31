import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ChannelMeeting.dart';
import 'ChatProvider.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatChannel channel;

  const ChatDetailScreen({super.key, required this.channel});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.blueGrey, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JitsiMeetPage(roomName: '',),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final channel = chatProvider.channels.firstWhere((c) => c.name == widget.channel.name);
                return ListView.builder(
                  itemCount: channel.messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(channel.messages[index]));
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
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Введите сообщение"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                      chatProvider.addMessageToChannel(widget.channel.name as int, _messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
