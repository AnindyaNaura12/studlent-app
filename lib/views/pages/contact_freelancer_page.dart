import 'package:flutter/material.dart';
import '../../models/message_model.dart';

class ContactFreelancerPage extends StatefulWidget {
  final String freelancerName;
  final String image;

  const ContactFreelancerPage({
    super.key,
    required this.freelancerName,
    required this.image,
  });

  @override
  State<ContactFreelancerPage> createState() =>
      _ContactFreelancerPageState();
}

class _ContactFreelancerPageState extends State<ContactFreelancerPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [
    Message(
      text: "Hi Putri,\nMay I ask you some question?",
      isSender: true,
      time: DateTime.now(),
    ),
    Message(
      text: "Hi Alex\nSure, How can I help you?",
      isSender: false,
      time: DateTime.now(),
    ),
  ];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        Message(
          text: _controller.text,
          isSender: true,
          time: DateTime.now(),
        ),
      );
    });

    _controller.clear();

    // auto scroll ke bawah
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8CCB4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD8CCB4),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.freelancerName,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          // ================= CHAT AREA =================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  return Align(
                    alignment: msg.isSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: msg.isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!msg.isSender)
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage(widget.image),
                          ),

                        if (!msg.isSender) const SizedBox(width: 6),

                        _chatBubble(msg),

                        if (msg.isSender) const SizedBox(width: 6),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ================= INPUT =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.grey),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type message",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _chatBubble(Message msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: msg.isSender ? const Color(0xFFFFE0B2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(msg.text),

          const SizedBox(height: 4),

          Text(
            formatTime(msg.time),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}