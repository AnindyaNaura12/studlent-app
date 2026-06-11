import 'package:flutter/material.dart';
import '../widgets/chat_item_tile.dart';
import '../../models/chat_model.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import 'contact_freelancer_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../widgets/custom_back_button.dart';

class ChatListPage extends StatefulWidget {
  final bool isFreelancerMode;
  const ChatListPage({super.key, this.isFreelancerMode = false});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatController _chatController = ChatController();
  final AuthController _authController = AuthController();

  final TextEditingController _searchController = TextEditingController();

  // 1. UBAH DARI Future MENJADI Stream
  late Stream<List<ChatModel>> _chatListStream;
  bool _isLoggedIn = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkAuthAndLoad() {
    _isLoggedIn = _authController.supabase.auth.currentUser != null;
    if (_isLoggedIn) {
      // 2. GUNAKAN FUNGSI STREAM DARI CONTROLLER
      _chatListStream = _chatController.getChatContactsStream();
    }
  }

  List<ChatModel> _filterChats(List<ChatModel> chats) {
    if (_searchQuery.trim().isEmpty) return chats;

    final query = _searchQuery.toLowerCase().trim();

    return chats.where((chat) {
      final name = chat.name.toLowerCase();
      final lastMessage = chat.lastMessage.toLowerCase();
      return name.contains(query) || lastMessage.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.85, size * 1.2);

    if (!_isLoggedIn) {
      return _buildLoginPlaceholder(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(child: _buildChatContent(scale)),
    );
  }

  Widget _buildLoginPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD59E), Colors.white],
          stops: [0.0, 0.55],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Chat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Welcome to Chat!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Login or register to connect\nwith freelancers or clients',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8D8C0), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "You're not logged in yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please login or register\nto view your messages',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(isFromChat: true),
                            ),
                          ).then((_) => setState(() => _checkAuthAndLoad()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(isFromChat: true),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(double Function(double) scale) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Center(
      child: Container(
        width: isWeb ? 900 : double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 0),
        child: Column(
          children: [
            SizedBox(height: scale(16)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                scale(20),
                scale(20),
                scale(20),
                scale(8),
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    Padding(
                      padding: EdgeInsets.only(right: scale(12)),
                      child: CustomBackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  Text(
                    widget.isFreelancerMode ? "Client Messages" : "Chat",
                    style: TextStyle(
                      fontSize: isWeb ? 26 : scale(22),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scale(8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale(20)),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(fontSize: scale(14)),
                decoration: InputDecoration(
                  hintText: "Search messages or freelancers",
                  hintStyle: TextStyle(fontSize: scale(13)),
                  prefixIcon: Icon(Icons.search, size: scale(20)),
                  suffixIcon: _searchQuery.trim().isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: Icon(Icons.close, size: scale(18)),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: scale(12)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(scale(30)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: scale(6)),

            // 3. UBAH FutureBuilder MENJADI StreamBuilder
            Expanded(
              child: StreamBuilder<List<ChatModel>>(
                stream:
                    _chatListStream, // Menggunakan stream yang sudah didefinisikan
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Terjadi kesalahan saat memuat chat.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: scale(14),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada obrolan.\nSilakan hubungi freelancer dari menu Booking/Services!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: scale(14),
                        ),
                      ),
                    );
                  }

                  final filteredChats = _filterChats(snapshot.data!);

                  if (filteredChats.isEmpty) {
                    return Center(
                      child: Text(
                        "Chat tidak ditemukan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: scale(14),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: scale(8)),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = filteredChats[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? scale(10) : scale(16),
                          vertical: scale(4),
                        ),
                        child: ChatItemTile(
                          chat: chat,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContactFreelancerPage(
                                  freelancerId: chat.freelancerId,
                                  freelancerName: chat.name,
                                  image: chat.imagePath,
                                ),
                              ),
                            ).then((_) => setState(() => _checkAuthAndLoad()));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
