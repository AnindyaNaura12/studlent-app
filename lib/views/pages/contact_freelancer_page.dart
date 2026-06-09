import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../controllers/chat_controller.dart';

class ContactFreelancerPage extends StatefulWidget {
  final int freelancerId;
  final String freelancerName;
  final String image;

  const ContactFreelancerPage({
    required this.freelancerId,
    super.key,
    required this.freelancerName,
    required this.image,
  });

  @override
  State<ContactFreelancerPage> createState() => _ContactFreelancerPageState();
}

class _ContactFreelancerPageState extends State<ContactFreelancerPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Inisialisasi Controller sesuai arsitektur MVC
  final ChatController _chatController = ChatController();

  int? _myUserId;
  Stream<List<Message>>? _messagesStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatContext();
  }

  // Mempersiapkan data secara aman melalui Controller sebelum menampilkan chat
  Future<void> _loadChatContext() async {
    final userId = await _chatController.getMyUserId();

    if (userId != null) {
      await _chatController.markMessagesAsRead(widget.freelancerId);
    }

    if (mounted) {
      setState(() {
        _myUserId = userId;

        if (userId != null) {
          _messagesStream = _chatController.getMessagesStream(
            widget.freelancerId,
          );
        }

        _isLoading = false;
      });
    }
  }

  // Menangani aksi kirim pesan
  Future<void> _handleSendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _myUserId == null) return;

    _controller.clear(); // Bersihkan textfield langsung demi UX yang cepat

    try {
      // Mendelegasikan logika pengiriman data ke Controller
      await _chatController.sendMessage(text, widget.freelancerId);
      _scrollToBottom();
    } catch (e) {
      debugPrint("Gagal memproses pengiriman pesan: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal(); 
    
    return "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================= CHAT ROOM AREA =================
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: _messagesStream == null
                        ? const Center(child: Text("Unable to load the chat room."))
                        : StreamBuilder<List<Message>>(
                            stream: _messagesStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Ups, terjadi kesalahan: ${snapshot.error}",
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "Belum ada pesan. Mulai obrolan!",
                                  ),
                                );
                              }
                              if (_myUserId == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final messages = snapshot.data!;

                              // Otomatis gulir ke pesan terbawah saat ada pesan baru masuk
                              _scrollToBottom();

                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];

                                  // Evaluasi posisi bubble chat: jika sender_id == ID kita, letakkan di KANAN
                                  final isSender =
                                      _myUserId != null &&
                                      int.tryParse(msg.senderId.toString()) ==
                                          _myUserId;

                                  return Align(
                                    alignment: isSender
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment: isSender
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!isSender)
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundImage: AssetImage(
                                              widget.image,
                                            ),
                                          ),
                                        if (!isSender) const SizedBox(width: 6),

                                        _buildChatBubble(msg, isSender),

                                        if (isSender) const SizedBox(width: 6),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),

                // ================= INPUT TEXT FIELD AREA =================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type message",
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _handleSendMessage,
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
                ),
              ],
            ),
    );
  }

  // Widget Bubble Chat Komponen Komponen UI
  Widget _buildChatBubble(Message msg, bool isSender) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: isSender ? const Color(0xFFFFE0B2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(msg.text),
          const SizedBox(height: 4),
          Text(
            _formatTime(msg.time),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
