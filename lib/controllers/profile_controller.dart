import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../views/pages/my_services_page.dart';
import '../views/pages/my_profile_page.dart';
import '../views/pages/my_orders_page.dart';
import '../views/pages/login_page.dart';
import '../views/pages/add_portfolio_page.dart';
import '../views/pages/home_pages.dart';
import '../views/pages/portfolio_list_page.dart';
import '../views/pages/register_freelancer_page.dart';

class ProfileController {
  final supabase = Supabase.instance.client;
  bool isFreelancer = false;
  bool isLoggedIn = false;

  static bool isFreelancerUnlocked = false;

  static void unlockFreelancer() {
    isFreelancerUnlocked = true;
  }

  static void lockFreelancer() {
    isFreelancerUnlocked = false;
  }

  // ── Get Client User ───────────────────────────────────────
  UserModel getClientUser() {
    return UserModel(
      username: '',
      name: '',
      role: 'Client',
      university: '',
      specialty: '',
      avatarPath: 'assets/images/icons/profile.png',
      email: '',
      location: '',
      myOrders: 0,
      totalSpent: 'Rp 0',
      completedOrders: 0,
      password: '',
    );
  }

  // ── Get Freelancer User ───────────────────────────────────
  UserModel getFreelancerUser() {
    return UserModel(
      username: '',
      name: '',
      role: 'Freelancer',
      university: '',
      specialty: '',
      avatarPath: 'assets/images/icons/profile.png',
      email: '',
      location: '',
      services: 0,
      rating: 0.0,
      earned: 'Rp 0',
    );
  }

  // ── Client Menu Items ─────────────────────────────────────
  // "Logout" di sini memanggil supabase.auth.signOut() via onMenuTap
  List<Map<String, dynamic>> getClientMenuItems() {
    return [
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  // ── Freelancer Menu Items ─────────────────────────────────
  // "Logout Freelancer" hanya reset lokal (tanpa signOut),
  // ditangani langsung di View dengan setState.
  List<Map<String, dynamic>> getFreelancerMenuItems() {
    return [
      {'title': 'My Profile', 'hasTag': true},
      {'title': 'Chat', 'hasTag': false},
      {'title': 'My Portfolio', 'hasTag': false},
      {'title': 'My Orders', 'hasTag': false},
      {'title': 'My Services', 'hasTag': false},
      {'title': 'Logout Freelancer', 'hasTag': false}, // local reset only
    ];
  }

  // ── Freelancer Stats ──────────────────────────────────────
  Future<Map<String, dynamic>> getFreelancerStats(
    int idUser,
    String period,
  ) async {
    try {
      final services = await supabase
          .from('services')
          .select('id_service')
          .eq('id_freelancer', idUser);

      final reviews = await supabase
          .from('reviews')
          .select('rating')
          .eq('id_freelancer', idUser);

      double ratingAvg = 0;

      if ((reviews as List).isNotEmpty) {
        final total = reviews.fold<double>(
          0,
          (sum, review) => sum + ((review['rating'] ?? 0) as num).toDouble(),
        );
        ratingAvg = total / reviews.length;
      }

      final now = DateTime.now();
      late DateTime fromDate;

      switch (period) {
        case 'weekly':
          fromDate = now.subtract(const Duration(days: 7));
          break;
        case 'yearly':
          fromDate = DateTime(now.year, 1, 1);
          break;
        case 'monthly':
        default:
          fromDate = DateTime(now.year, now.month, 1);
          break;
      }

      final freelancerProfile = await supabase
          .from('freelancer_profiles')
          .select('created_at')
          .eq('id_user', idUser)
          .maybeSingle();

      final freelancerCreatedAt = DateTime.tryParse(
            freelancerProfile?['created_at']?.toString() ?? '',
          ) ??
          now;

      final orders = await supabase
          .from('orders')
          .select('id_order')
          .eq('id_freelancer', idUser)
          .eq('status', 'selesai');

      double earned = 0;

      if ((orders as List).isNotEmpty) {
        final orderIds = orders.map((e) => e['id_order']).toList();

        final payments = await supabase
            .from('payments')
            .select('amount, admin_fee, freelancer_receive, tanggal_bayar')
            .inFilter('id_order', orderIds);

        for (final payment in payments as List) {
          final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
          final adminFee = (payment['admin_fee'] as num?)?.toDouble() ?? 0;
          final servicePrice = amount - adminFee;

          final trxDate = DateTime.tryParse(
                payment['tanggal_bayar']?.toString() ?? '',
              ) ??
              now;

          if (trxDate.isBefore(fromDate)) continue;

          final monthDiff =
              (trxDate.year - freelancerCreatedAt.year) * 12 +
                  (trxDate.month - freelancerCreatedAt.month);

          final feePercent = monthDiff < 2 ? 0.05 : 0.08;
          final netEarned = servicePrice * (1 - feePercent);

          earned += netEarned;
        }
      }

      return {
        'services': (services as List).length,
        'rating': double.parse(ratingAvg.toStringAsFixed(1)),
        'earned': earned,
      };
    } catch (e) {
      debugPrint('getFreelancerStats error: $e');
      return {'services': 0, 'rating': 0.0, 'earned': 0.0};
    }
  }

  // ── Fetch user + statistik ────────────────────────────────
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        isLoggedIn = false;
        return null;
      }

      final user = await supabase
          .from('users')
          .select()
          .eq('email', authUser.email!)
          .single();

      isLoggedIn = true;
      isFreelancer = user['is_freelancer'] == true;

      String professionalStatus = '';
      if (isFreelancer) {
        final profileData = await supabase
            .from('freelancer_profiles')
            .select('professional_status')
            .eq('id_user', user['id_user'])
            .maybeSingle();

        if (profileData != null) {
          professionalStatus = profileData['professional_status'] ?? '';
        }
      }

      final orders = await supabase
          .from('orders')
          .select('id_order, status')
          .eq('id_client', user['id_user']);

      final completedOrders = (orders as List)
          .where((o) => o['status'] == 'selesai')
          .length;

      double totalSpent = 0;
      if (orders.isNotEmpty) {
        final orderIds = orders.map((o) => o['id_order']).toList();

        final payments = await supabase
            .from('payments')
            .select('amount, admin_fee')
            .inFilter('id_order', orderIds)
            .eq('status', 'pending');

        for (final p in payments as List) {
          final amount = (p['amount'] as num?)?.toDouble() ?? 0;
          final adminFee = (p['admin_fee'] as num?)?.toDouble() ?? 0;
          totalSpent += (amount - adminFee);
        }
      }

      return {
        ...user,
        'professional_status': professionalStatus,
        'my_orders': orders.length,
        'completed_orders': completedOrders,
        'total_spent': totalSpent,
      };
    } catch (e) {
      debugPrint('getCurrentUser error: $e');
      isLoggedIn = false;
      return null;
    }
  }

  // ── Upload foto profil ────────────────────────────────────
  Future<String?> uploadProfileImage(
    int idUser, {
    bool isFreelancer = false,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 500,
      );
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      final mimeType = picked.mimeType ?? 'image/jpeg';
      final extension = mimeType.split('/').last;

      final prefix = isFreelancer ? 'freelancer' : 'client';
      final fileName = '${prefix}_$idUser.$extension';

      final formats = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
      for (final ext in formats) {
        try {
          await supabase.storage.from('Profile-image').remove([
            '${prefix}_$idUser.$ext',
          ]);
        } catch (_) {}
      }

      await supabase.storage
          .from('Profile-image')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mimeType),
          );

      final imageUrl = supabase.storage
          .from('Profile-image')
          .getPublicUrl(fileName);

      final updateField = isFreelancer ? 'foto_freelancer' : 'foto';
      await supabase
          .from('users')
          .update({
            updateField: imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_user', idUser);

      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('uploadProfileImage error: $e');
      return null;
    }
  }

  // ── Update data profil ────────────────────────────────────
  Future<bool> updateProfile({
    required int idUser,
    required String nama,
    required String username,
    required String noHp,
  }) async {
    try {
      await supabase
          .from('users')
          .update({
            'nama': nama,
            'username': username,
            'no_hp': noHp,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_user', idUser);
      return true;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }

  // ── Update password ───────────────────────────────────────
  Future<bool> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      debugPrint('updatePassword error: $e');
      return false;
    }
  }

  // ── Logout Supabase penuh (untuk Client) ──────────────────
  Future<void> logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 4)),
      (route) => false,
    );
  }

  // ── Menu Tap Handler ──────────────────────────────────────
  // "Logout Freelancer" tidak ada di sini karena ditangani
  // langsung di View (setState lokal, tanpa signOut).
  void onMenuTap(String title, BuildContext context) {
    switch (title) {
      case 'My Services':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyServicesPage()),
        );
        break;
      case 'My Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileFreelancerPage()),
        );
        break;
      case 'My Orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersPage()),
        );
        break;
      case 'My Portfolio':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PortfolioListPage()),
        );
        break;
      case 'Logout':
        // Hanya dipanggil dari menu Client — signOut penuh
        logout(context);
        break;
    }
  }
}
