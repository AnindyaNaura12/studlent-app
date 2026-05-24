import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatController {
  final supabase = Supabase.instance.client;
  int? _cachedUserId;

  // 1. Mengambil ID pengguna (int) dari user yang sedang login via email Auth
  Future<int?> getMyUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null || currentUser.email == null) return null;
    
    try {
      final userData = await supabase
          .from('users')
          .select('id_user')
          .eq('email', currentUser.email!)
          .maybeSingle();
          
      final rawId = userData?['id_user'];
      _cachedUserId = rawId != null ? int.tryParse(rawId.toString()) : null;
      return _cachedUserId;
    } catch (e) {
      print("Error fetching user ID: $e");
      return null;
    }
  }

  // 2. Mengambil Daftar Kontak Chat Terkini (Untuk halaman Chat List)
  Future<List<ChatModel>> getRealChatContacts() async {
    final myUserId = await getMyUserId();
    if (myUserId == null) return [];

    try {
      final response = await supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$myUserId,receiver_id.eq.$myUserId')
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      Map<int, Map<String, dynamic>> latestMessages = {};

      for (var msg in response) {
        int senderId = msg['sender_id'] as int;
        int receiverId = msg['receiver_id'] as int;
        int otherId = (senderId == myUserId) ? receiverId : senderId;

        if (!latestMessages.containsKey(otherId)) {
          latestMessages[otherId] = {
            'lastMessage': msg['text'],
            'created_at': msg['created_at'],
          };
        }
      }

      final List<int> otherUserIds = latestMessages.keys.toList();
      final usersResponse = await supabase
          .from('users')
          .select('''
            id_user, 
            nama, 
            foto,
            freelancer_profiles (
              professional_status,
              foto_freelancer
            )
          ''').inFilter('id_user', otherUserIds);

      List<ChatModel> chatList = [];
      for (var user in usersResponse) {
        int userId = user['id_user'];
        String role = 'Freelancer';
        String image = 'assets/images/icons/profile.png';

        final fp = user['freelancer_profiles'];
        if (fp != null) {
          if (fp is List && fp.isNotEmpty) {
            role = fp[0]['professional_status'] ?? role;
            if (fp[0]['foto_freelancer'] != null) image = fp[0]['foto_freelancer'];
          } else if (fp is Map) {
            role = fp['professional_status'] ?? role;
            if (fp['foto_freelancer'] != null) image = fp['foto_freelancer'];
          }
        }

        if (image == 'assets/images/icons/profile.png' && user['foto'] != null) {
          image = user['foto'];
        }

        chatList.add(ChatModel(
          freelancerId: userId,
          name: user['nama'] ?? 'Unknown',
          role: role,
          lastMessage: latestMessages[userId]?['lastMessage'] ?? '',
          time: latestMessages[userId]?['created_at'] != null 
              ? DateTime.parse(latestMessages[userId]!['created_at']) 
              : DateTime.now(),
          imagePath: (user['foto'] != null && user['foto'].toString().isNotEmpty)
              ? user['foto']
              : 'assets/images/freelancers/freelancer_1.png', 
        ));
      }

      chatList.sort((a, b) {
        DateTime timeA = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime timeB = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA);
      });

      return chatList;
    } catch (e) {
      print("Error fetching chat list: $e");
      return [];
    }
  }

  // 3. Stream Khusus Room Chat (Memfilter pesan hanya antara Saya dan Freelancer ini)
  Stream<List<Message>> getMessagesStream(int targetFreelancerId) async* {
    final myUserId = await getMyUserId();
    if (myUserId == null) {
      yield [];
      return;
    }

    yield* supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          final filteredData = data.where((json) {
            final sender = int.tryParse(json['sender_id'].toString());
            final receiver = int.tryParse(json['receiver_id'].toString());
            return (sender == myUserId && receiver == targetFreelancerId) ||
                (sender == targetFreelancerId && receiver == myUserId);
          }).toList();
          return filteredData.map((json) => Message.fromJson(json)).toList();
        });
  }

  // 4. Aksi Mengirim Pesan ke Database Supabase
  Future<void> sendMessage(String text, int targetFreelancerId) async {
    final myUserId = await getMyUserId();
    if (myUserId == null) return;

    try {
      await supabase.from('messages').insert({
        'text': text,
        'sender_id': myUserId,
        'receiver_id': targetFreelancerId,
      });
    } catch (e) {
      print("Gagal kirim pesan: $e");
    }
  }
}