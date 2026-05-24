class Message {
  final String id;
  final String text;
  final int senderId;
  final int receiverId;
  final DateTime time;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      receiverId: int.tryParse(json['receiver_id'].toString()) ?? 0,
      text: json['text'] as String,
      time: DateTime.parse(json['created_at']),
    );
  }
}