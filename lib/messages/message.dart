class Message {
  final String content;
  final String senderId;
  final DateTime createAt;
  final bool isMine;

  Message({
    required this.content,
    required this.senderId,
    required this.createAt,
    required this.isMine,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      content: json['text'],
      senderId: json['sender_id'],
      createAt: DateTime.parse(json['created_at']),
      isMine: json['sender_id'] == currentUserId,
    );
  }
}