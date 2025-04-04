
import 'package:flutter/material.dart';

import 'message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var chatContents = [
      const SizedBox(width: 5.0),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: message.isMine ? Colors.grey[600] : Colors.indigo[400],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message.content,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(width: 5),
      Text(message.createAt.toString(),
          style: const TextStyle(color: Colors.grey, fontSize: 12.0)),
      const SizedBox(width: 40),
    ];

    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment:
        message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}