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

  String _resolveUserImage(Map<String, dynamic> user) {
    final fp = user['freelancer_profiles'];
    if (fp != null) {
      String? fotoFreelancer;
      if (fp is List && fp.isNotEmpty) {
        fotoFreelancer = fp[0]['foto_freelancer']?.toString();
      } else if (fp is Map) {
        fotoFreelancer = fp['foto_freelancer']?.toString();
      }
      if (fotoFreelancer != null && fotoFreelancer.isNotEmpty) {
        return fotoFreelancer;
      }
    }

    final foto = user['foto']?.toString();
    if (foto != null && foto.isNotEmpty) {
      return foto;
    }

    return 'assets/images/icons/profile.png';
  }

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
            'unread': 0,
          };
        }

        if (receiverId == myUserId && msg['is_read'] == false) {
          latestMessages[otherId]!['unread'] =
              (latestMessages[otherId]!['unread'] ?? 0) + 1;
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
        String role = 'Client'; 
        final fp = user['freelancer_profiles'];
        if (fp != null) {
          if (fp is List && fp.isNotEmpty) {
            role = fp[0]['professional_status'] ?? role;
          } else if (fp is Map) {
            role = fp['professional_status'] ?? role;
          }
        }

        final resolvedImage = _resolveUserImage(user);

        chatList.add(
          ChatModel(
            freelancerId: userId,
            name: user['nama'] ?? 'Unknown',
            role: role,
            lastMessage: latestMessages[userId]?['lastMessage'] ?? '',
            time: latestMessages[userId]?['created_at'] != null
                ? DateTime.parse(latestMessages[userId]!['created_at'])
                : DateTime.now(),
            imagePath: resolvedImage,
            unreadCount: latestMessages[userId]?['unread'] ?? 0,
          ),
        );
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

  // =========================================================================
  // FUNGSI BARU: Stream untuk Chat List agar real-time (TIDAK MERUSAK FUNGSI LAIN)
  // =========================================================================
  Stream<List<ChatModel>> getChatContactsStream() async* {
    final myUserId = await getMyUserId();
    if (myUserId == null) {
      yield [];
      return;
    }

    yield* supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .asyncMap((messagesData) async {
      
      final relevantMessages = messagesData.where((msg) {
        final senderId = int.tryParse(msg['sender_id'].toString());
        final receiverId = int.tryParse(msg['receiver_id'].toString());
        return senderId == myUserId || receiverId == myUserId;
      }).toList();

      relevantMessages.sort((a, b) {
        DateTime timeA = DateTime.parse(a['created_at']);
        DateTime timeB = DateTime.parse(b['created_at']);
        return timeB.compareTo(timeA);
      });

      Map<int, Map<String, dynamic>> latestMessages = {};
      for (var msg in relevantMessages) {
        int senderId = int.tryParse(msg['sender_id'].toString()) ?? 0;
        int receiverId = int.tryParse(msg['receiver_id'].toString()) ?? 0;
        int otherId = (senderId == myUserId) ? receiverId : senderId;

        if (!latestMessages.containsKey(otherId)) {
          latestMessages[otherId] = {
            'lastMessage': msg['text'],
            'created_at': msg['created_at'],
            'unread': 0,
          };
        }

        if (receiverId == myUserId && msg['is_read'] == false) {
          latestMessages[otherId]!['unread'] =
              (latestMessages[otherId]!['unread'] ?? 0) + 1;
        }
      }

      if (latestMessages.isEmpty) return <ChatModel>[];

      final otherUserIds = latestMessages.keys.toList();
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
        String role = 'Client';
        final fp = user['freelancer_profiles'];
        if (fp != null) {
          if (fp is List && fp.isNotEmpty) {
            role = fp[0]['professional_status'] ?? role;
          } else if (fp is Map) {
            role = fp['professional_status'] ?? role;
          }
        }

        final resolvedImage = _resolveUserImage(user);

        chatList.add(
          ChatModel(
            freelancerId: userId,
            name: user['nama'] ?? 'Unknown',
            role: role,
            lastMessage: latestMessages[userId]?['lastMessage'] ?? '',
            time: latestMessages[userId]?['created_at'] != null
                ? DateTime.parse(latestMessages[userId]!['created_at']).toLocal()
                : DateTime.now().toLocal(),
            imagePath: resolvedImage,
            unreadCount: latestMessages[userId]?['unread'] ?? 0,
          ),
        );
      }

      chatList.sort((a, b) {
        DateTime timeA = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime timeB = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA);
      });

      return chatList;
    });
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
        .order('created_at', ascending: false)
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
        'is_read': false,
      });
    } catch (e) {
      print("Gagal kirim pesan: $e");
    }
  }
  
  Future<void> markMessagesAsRead(int otherUserId) async {
    final myUserId = await getMyUserId();
    if (myUserId == null) return;

    try {
      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', otherUserId)
          .eq('receiver_id', myUserId)
          .eq('is_read', false);
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }
}