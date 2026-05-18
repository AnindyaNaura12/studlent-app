class Message {
  final String id;
  final String text;
  final int senderId;
  final DateTime time;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      senderId: json['sender_id'] as int? ?? 0,
      time: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}