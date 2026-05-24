// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ← TAMBAH INI
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
  final ChatController _chatController = ChatController();
  final SupabaseClient supabase = Supabase.instance.client;

  int? _myUserId;
  bool _loadingUserId = true;
  Stream<List<Message>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final userId = await _chatController.getMyUserId();
    if (!mounted) return;

    Stream<List<Message>>? stream;
    if (userId != null) {
      stream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .map((data) {
            return data
                .where((json) {
                  final sender = json['sender_id'] as int?;
                  final receiver = json['receiver_id'] as int?;
                  return (sender == userId && receiver == widget.freelancerId) ||
                      (sender == widget.freelancerId && receiver == userId);
                })
                .map((json) => Message.fromJson(json))
                .toList();
          });
    }

    setState(() {
      _myUserId = userId;
      _messagesStream = stream;
      _loadingUserId = false;
    });
  }

  // ← FIX: Future.delayed sekarang di dalam fungsi sendMessage
  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (_myUserId == null) return;

    final text = _controller.text.trim();
    _controller.clear();

    try {
      await supabase.from('messages').insert({
        'text': text,
        'sender_id': _myUserId,
        'receiver_id': widget.freelancerId,
      });
    } catch (e) {
      debugPrint("Gagal memproses pengiriman pesan: $e");
    }

    // ← FIX: ini harus di dalam sendMessage, bukan di luar
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

  // ← FIX: nama konsisten jadi formatTime
  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
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
        leading: const BackButton(color: Colors.black),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.image.isNotEmpty &&
                      widget.image.startsWith('http')
                  ? NetworkImage(widget.image)
                  : null,
              child: widget.image.isEmpty || !widget.image.startsWith('http')
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.freelancerName,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
      body: _loadingUserId
          ? const Center(child: CircularProgressIndicator())
          : _myUserId == null
              ? const Center(
                  child: Text(
                    'Silakan login untuk chat',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: StreamBuilder<List<Message>>(
                          stream: _messagesStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final messages = snapshot.data ?? [];

                            if (messages.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble_outline,
                                        size: 48,
                                        color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Belum ada pesan.\nMulai percakapan!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                              }
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                // ← FIX: pakai _myUserId bukan widget.freelancerId
                                final isSender = msg.senderId == _myUserId;

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
                                      if (!isSender) ...[
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: widget
                                                      .image.isNotEmpty &&
                                                  widget.image
                                                      .startsWith('http')
                                              ? NetworkImage(widget.image)
                                                  as ImageProvider
                                              : null,
                                          child: widget.image.isEmpty ||
                                                  !widget.image
                                                      .startsWith('http')
                                              ? const Icon(Icons.person,
                                                  size: 14)
                                              : null,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      // ← FIX: nama method konsisten
                                      _chatBubble(msg, isSender),
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

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => sendMessage(),
                              decoration: InputDecoration(
                                hintText: "Type message",
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16),
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
                              child: const Icon(Icons.send,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // ← FIX: nama jadi _chatBubble (konsisten dengan yang dipanggil di atas)
  Widget _chatBubble(Message msg, bool isSender) {
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
          // ← FIX: nama konsisten formatTime
          Text(
            formatTime(msg.time),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}