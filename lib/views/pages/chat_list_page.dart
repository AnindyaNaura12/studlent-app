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

    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 RESPONSIVE SCALE (FIXED)
    double scale(double size) {
      double factor = screenWidth / 375;

      if (factor > 1.2) factor = 1.2;
      if (factor < 0.85) factor = 0.85;

      return size * factor;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 600;

            return Center(
              child: Container(
                width: isWeb ? 900 : double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 40 : 0,
                ),
                child: Column(
                  children: [

                    SizedBox(height: scale(16)),

                    // ================= HEADER =================
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        scale(20),
                        scale(20),
                        scale(20),
                        scale(8),
                      ),
                      child: Text(
                        "Chat",
                        style: TextStyle(
                          fontSize: isWeb ? 26 : scale(22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: scale(8)),

                    // ================= SEARCH =================
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: scale(20)),
                      child: TextField(
                        style: TextStyle(fontSize: scale(14)),
                        decoration: InputDecoration(
                          hintText: "Search messages or freelancers",
                          hintStyle: TextStyle(fontSize: scale(13)),
                          prefixIcon: Icon(Icons.search, size: scale(20)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: scale(12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(scale(30)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: scale(6)),

                    // ================= CHAT LIST =================
                    Expanded(
                      child: isWeb
                          ? ListView.builder(
                              padding: EdgeInsets.symmetric(
                                vertical: scale(12),
                                horizontal: scale(10),
                              ),
                              itemCount: chatList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: scale(4),
                                  ),
                                  child: ChatItemTile(
                                    chat: chatList[index],
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                vertical: scale(8),
                              ),
                              itemCount: chatList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: scale(16),
                                    vertical: scale(0),
                                  ),
                                  child: ChatItemTile(
                                    chat: chatList[index],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}