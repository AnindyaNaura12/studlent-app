// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/pages/detail_profile_freelancer.dart';
import '../models/services_model.dart';
import '../views/pages/service_detail_page.dart';
import '../views/pages/login_page.dart';
import '../views/pages/detail_order_page.dart';

class MyServicesController {
  final supabase = Supabase.instance.client;

  // ── Cek status login ──────────────────────────────────────
  // ← PERBAIKAN: pakai currentSession, bukan currentUser
  bool get isLoggedIn => supabase.auth.currentSession != null;

  int? _cachedUserId;

  int? get currentUserId => _cachedUserId;

  Future<int?> fetchCurrentUserId() async {
    if (!isLoggedIn) return null;

    final email = supabase.auth.currentUser?.email;
    if (email == null) return null;

    final data = await supabase
        .from('users')
        .select('id_user')
        .eq('email', email)
        .maybeSingle();

    _cachedUserId = data?['id_user'] as int?;
    return _cachedUserId;
  }

  // ── Navigasi ke Order Now dengan cek login ────────────────
  void goToOrderNow(BuildContext context, ServiceModel service) {
    // Cek ulang session saat tombol ditekan (bukan dari cache)
    final loggedIn = supabase.auth.currentSession != null;

    if (!loggedIn) {
      // Belum login → ke LoginPage dengan redirect ke DetailOrderPage setelah login
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(redirectToService: service),
        ),
      );
    } else {
      // Sudah login → langsung ke DetailOrderPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailOrderPage(service: service),
        ),
      );
    }
  }

  // ── Daftar service dummy (fallback) ──────────────────────
  List<ServiceModel> services = [
    ServiceModel(
      id: '11',
      title: 'App Design - StudyBuddy',
      category: 'Design',
      description: 'Modern UI for study group organization',
      imagePath: null,
      serviceImages: [],
      basicPackage: PackageModel(
        price: 'Rp. 180.000',
        deliveryTime: '3 days',
        shortDescription: '2 Modern Concepts + Vector Files + Favicon',
      ),
    ),
    ServiceModel(
      id: '2',
      title: 'Web Design - Organization',
      category: 'Design Web',
      description: 'Custom shopify store design + ecommerce development',
      imagePath: 'assets/images/portfolio_sample.png',
      serviceImages: [],
      basicPackage: PackageModel(
        price: 'Rp. 180.000',
        deliveryTime: '3 days',
        shortDescription: '2 Modern Concepts + Vector Files + Favicon',
      ),
    ),
  ];

  // ── Fetch services dari Supabase ──────────────────────────
  Future<List<ServiceModel>> fetchServicesFromSupabase() async {
    try {
      final data = await supabase
          .from('service_detail')
          .select()
          .eq('status', 'approved')
          .order('rating_avg', ascending: false);

      return (data as List).map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      return services; // fallback ke dummy data
    }
  }

  // ── Package helpers ───────────────────────────────────────
  String getPackageTitle(int selectedTab) {
    switch (selectedTab) {
      case 0: return 'Basic Package';
      case 1: return 'Standard Package';
      case 2: return 'Premium Package';
      default: return '';
    }
  }

  String getPackageDescription(int selectedTab, ServiceModel service) {
    switch (selectedTab) {
      case 0: return service.basicPackage.shortDescription ?? '';
      case 1: return '2 Concepts + Vector Files + Favicon';
      case 2: return '3 Concepts + All Files + Source + Priority';
      default: return '';
    }
  }

  String getPackagePrice(int selectedTab, ServiceModel service) {
    switch (selectedTab) {
      case 0: return service.basicPackage.price;
      case 1: return service.basicPackage.price;
      case 2: return 'Rp 500.000';
      default: return '';
    }
  }

  // ── Navigasi lainnya ──────────────────────────────────────
  void goToProfile(BuildContext context, ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProfileFreelancer(service: service),
      ),
    );
  }

  void goToServiceDetail(BuildContext context, ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailPage(service: service),
      ),
    );
  }
}