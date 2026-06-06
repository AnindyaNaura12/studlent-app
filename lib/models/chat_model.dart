class ChatModel {
  final int freelancerId;
  final String name;
  final String role;
  final String lastMessage;
  final String imagePath;
  final DateTime? time;
  final int unreadCount;

  ChatModel({
    required this.freelancerId,
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.imagePath,
    this.time,
    this.unreadCount = 0,
  });
}