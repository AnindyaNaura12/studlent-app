import 'package:flutter/material.dart';
import '../widgets/chat_item_tile.dart';
import '../../models/chat_model.dart';
import '../../controllers/chat_controller.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController();
    final chatList = controller.getChats();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE), // Background krem konsisten
      body: Column(
        children: [
          const SizedBox(height: 50),
          // Header dengan tombol Back dan Judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Expanded(
                  child: Text(
                    "Chat",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 40), // Penyeimbang agar teks Chat tetap di tengah
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search messages or freelancers",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Daftar Chat
          Expanded(
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) => ChatItemTile(chat: chatList[index]),
            ),
          ),
        ],
      ),
    );
  }
}