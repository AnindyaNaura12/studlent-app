import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/message_model.dart';
import '../../main.dart';
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
  // Inisialisasi Supabase
  // final supabase = Supabase.instance.client;

  // CONTOH: Karena belum ada sistem Login, kita pakai ID pura-pura dulu
  // Nanti myUserId ini diganti dengan ID user yang sedang login (auth)
  final int myUserId = 10; 
  final int currentFreelancerId = 11; 

  late final Stream<List<Message>> _messagesStream;

  @override
  void initState() {
    super.initState();
    // 2. Inisialisasi stream HANYA SATU KALI di sini
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => Message.fromJson(json)).toList());
  }
  
  // Fungsi untuk mengambil pesan secara Real-Time
  Stream<List<Message>> _getMessagesStream() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true) // Urutkan pesan dari atas ke bawah
        .map((data) => data.map((json) => Message.fromJson(json)).toList());
  }

  // Fungsi mengirim pesan ke Database
  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    _controller.clear(); // Bersihkan kolom ketik

    try {
    // Masukkan ke tabel chat_messages di Supabase
    await supabase.from('messages').insert({
      'text': text,
      'sender_id': myUserId,
      'receiver_id': currentFreelancerId,
    });
    } catch (e) {
      debugPrint("Gagal kirim pesan: $e");
    }

    // Scroll ke paling bawah setelah kirim
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

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
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
          // ================= CHAT AREA (STREAM BUILDER) =================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: StreamBuilder<List<Message>>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Ups, ada error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  // Jika masih loading data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Jika tidak ada data pesan
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada pesan. Mulai obrolan!"));
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      // Mengecek apakah pesan ini milik kita atau orang lain
                      final isSender = msg.senderId != widget.freelancerId; 

                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isSender)
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: AssetImage(widget.image),
                              ),
                            if (!isSender) const SizedBox(width: 6),
                            
                            _chatBubble(msg, isSender), // Melempar status isSender
                            
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

          // ================= INPUT (TETAP SAMA) =================
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage, // Memanggil fungsi Supabase Insert
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

  // Menambahkan parameter isSender agar UI tahu warna apa yang dipakai
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
          Text(
            formatTime(msg.time),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}