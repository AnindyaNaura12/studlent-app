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

class ProfileController {
  final supabase = Supabase.instance.client;
  bool isFreelancer = false;
  bool isLoggedIn = false;

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
  List<Map<String, dynamic>> getClientMenuItems() {
    return [
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  // ── Freelancer Menu Items ─────────────────────────────────
  List<Map<String, dynamic>> getFreelancerMenuItems() {
    return [
      {'title': 'My Profile', 'hasTag': true},
      {'title': 'My Portfolio', 'hasTag': false},
      {'title': 'My Orders', 'hasTag': false},
      {'title': 'My Services', 'hasTag': false},
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  // ── Fetch user + statistik ────────────────────────────────
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        isLoggedIn = false;
        return null;
      }

      // Ambil data user
      final user = await supabase
          .from('users')
          .select()
          .eq('email', authUser.email!)
          .single();

      isLoggedIn = true;
      isFreelancer = user['role'] == 'freelancer';

      // Ambil semua orders client
      final orders = await supabase
          .from('orders')
          .select('id_order, status')
          .eq('id_client', user['id_user']);

      // Hitung completed orders
      final completedOrders = (orders as List)
          .where((o) => o['status'] == 'selesai')
          .length;

      // Hitung total spent dari payments
      double totalSpent = 0;
      if (orders.isNotEmpty) {
        final orderIds = orders.map((o) => o['id_order']).toList();
        final payments = await supabase
            .from('payments')
            .select('amount')
            .inFilter('id_order', orderIds)
            .eq('status', 'paid');

        for (var p in payments as List) {
          totalSpent += (p['amount'] ?? 0).toDouble();
        }
      }

      return {
        ...user,
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
  Future<String?> uploadProfileImage(int idUser) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 500,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      // Pakai id_user sebagai nama file → tidak duplikat
      final fileName = 'profile_$idUser.jpg';

      await supabase.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // Simpan url ke tabel users
      await supabase
          .from('users')
          .update({
            'foto': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_user', idUser);

      return imageUrl;
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

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout(BuildContext context) async {
    await supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ── Menu Items ───────────────────────────────────────────
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

      case 'My Portfolio': // ← TAMBAH DI SINI
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPortfolioPage()),
        );
        break;

      case 'Logout':
        logout(context);
        break;
    }
  }
}
