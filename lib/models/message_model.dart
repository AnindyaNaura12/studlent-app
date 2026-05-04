class Message {
  final String text;
  final bool isSender;
  final DateTime time;

  Message({
    required this.text,
    required this.isSender,
    required this.time,
  });
}