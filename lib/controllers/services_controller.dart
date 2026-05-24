// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/pages/detail_profile_freelancer.dart';
import '../models/services_model.dart';
import '../views/pages/service_detail_page.dart';
import '../views/pages/login_page.dart';
import '../views/pages/detail_order_page.dart';

class ServicesController {
  final supabase = Supabase.instance.client;

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

  // ── Fetch semua service aktif ─────────────────────────────
  Future<List<ServiceModel>> fetchServicesFromSupabase() async {
    try {
      final data = await supabase
          .from('service_detail')
          .select()
          .eq('status', 'active')
          .order('rating_avg', ascending: false);

      return (data as List).map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('ERROR FETCH SERVICES: $e');
      return [];
    }
  }

  // ── Fetch dengan filter ───────────────────────────────────
  Future<List<ServiceModel>> fetchServicesFiltered({
    String searchQuery = '',
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      var query = supabase
          .from('service_detail')
          .select()
          .eq('status', 'active');

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (minPrice != null) {
        query = query.gte('basic_price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('basic_price', maxPrice);
      }

      final data = await query.order('rating_avg', ascending: false);

      List<ServiceModel> results = (data as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        results = results.where((s) {
          return s.title.toLowerCase().contains(q) ||
              s.name.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q);
        }).toList();
      }

      return results;
    } catch (e) {
      debugPrint('ERROR FETCH FILTERED: $e');
      return [];
    }
  }

  // ── Dummy fallback ────────────────────────────────────────
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

  // ── Package helpers ───────────────────────────────────────
  String getPackageTitle(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return 'Basic Package';
      case 1:
        return 'Standard Package';
      case 2:
        return 'Premium Package';
      default:
        return '';
    }
  }

  String getPackageDescription(int selectedTab, ServiceModel service) {
    switch (selectedTab) {
      case 0:
        return service.basicPackage.shortDescription;
      case 1:
        return '2 Concepts + Vector Files + Favicon';
      case 2:
        return '3 Concepts + All Files + Source + Priority';
      default:
        return '';
    }
  }

  String getPackagePrice(int selectedTab, ServiceModel service) {
    switch (selectedTab) {
      case 0:
        return service.basicPackage.price;
      case 1:
        return service.basicPackage.price;
      case 2:
        return 'Rp 500.000';
      default:
        return '';
    }
  }

  // ── Navigasi ──────────────────────────────────────────────
  void goToOrderNow(BuildContext context, ServiceModel service) {
    final loggedIn = supabase.auth.currentSession != null;
    if (!loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(redirectToService: service),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailOrderPage(service: service)),
      );
    }
  }

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
      MaterialPageRoute(builder: (_) => ServiceDetailPage(service: service)),
    );
  }
}
