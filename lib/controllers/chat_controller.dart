import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatController {
  final supabase = Supabase.instance.client;

  // 1. Dapatkan id_user (int4) dari user yang sedang login saat ini (Client)
  Future<int?> getMyUserId() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null || currentUser.email == null) return null;
    
    try {
      // Menghubungkan Supabase Auth UUID dengan tabel public.users milikmu
      final userData = await supabase
          .from('users')
          .select('id_user')
          .eq('email', currentUser.email!)
          .maybeSingle();
          
      return userData?['id_user'] as int?;
    } catch (e) {
      print("Error fetching user ID: $e");
      return null;
    }
  }

  // 2. Fungsi Mengambil Daftar Obrolan Nyata (List Chat)
  Future<List<ChatModel>> getRealChatContacts() async {
    final myUserId = await getMyUserId();
    if (myUserId == null) return [];

    try {
      // Ambil semua pesan di mana user ini terlibat (sebagai pengirim atau penerima)
      final response = await supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$myUserId,receiver_id.eq.$myUserId')
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      // Mengelompokkan riwayat pesan berdasarkan lawan bicara (Freelancer)
      Map<int, Map<String, dynamic>> latestMessages = {};

      for (var msg in response) {
        int senderId = msg['sender_id'] as int;
        int receiverId = msg['receiver_id'] as int;
        
        // Lawan bicara adalah ID yang BUKAN diri kita sendiri
        int otherId = (senderId == myUserId) ? receiverId : senderId;

        // Simpan pesan pertama kali yang ditemukan (sudah terurut dari yang terbaru)
        if (!latestMessages.containsKey(otherId)) {
          latestMessages[otherId] = {
            'lastMessage': msg['text'],
            'created_at': msg['created_at'],
          };
        }
      }

      // Ambil data profil Freelancer dari tabel users
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
          ''')
          .inFilter('id_user', otherUserIds);

      // Bentuk List Model-nya
      List<ChatModel> chatList = [];
      for (var user in usersResponse) {
        int userId = user['id_user'];
        String role = 'Freelancer';
        String image = 'assets/images/icons/profile.png';

        final fp = user['freelancer_profiles'];
        if (fp != null) {
          // Supabase biasanya mengembalikan relasi 1-to-1 sebagai Map, atau 1-to-many sebagai List
          if (fp is List && fp.isNotEmpty) {
            role = fp[0]['professional_status'] ?? role;
            if (fp[0]['foto_freelancer'] != null) image = fp[0]['foto_freelancer'];
          } else if (fp is Map) {
            role = fp['professional_status'] ?? role;
            if (fp['foto_freelancer'] != null) image = fp['foto_freelancer'];
          }
        }

        // Fallback jika foto freelancer kosong tapi foto user ada
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

      // Urutkan list chat agar chat terbaru ada di urutan paling atas
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

  // 3. Fungsi Stream untuk Room Chat
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
            final sender = json['sender_id'] as int?;
            final receiver = json['receiver_id'] as int?;
            return (sender == myUserId && receiver == targetFreelancerId) ||
                   (sender == targetFreelancerId && receiver == myUserId);
          }).toList();
          return filteredData.map((json) => Message.fromJson(json)).toList();
        });
  }

  // 4. Kirim Pesan
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