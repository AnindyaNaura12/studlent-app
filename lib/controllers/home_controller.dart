import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/services_model.dart';
import '../models/category_model.dart';

class HomeController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// =========================
  /// KATEGORI 
  /// =========================
  /// Untuk homepage — hanya kategori yang punya icon (max 6)
  Future<List<CategoryModel>> getHomeCategories() async {
    try {
      final data = await _supabase
          .from('service_categories')
          .select('id_category, nama')
          .order('id_category', ascending: true);

      final List<CategoryModel> result = [];

      for (final e in data as List) {
        final title = e['nama'].toString();
        final iconPath = _getIconPath(title);
        if (iconPath == null) continue; // skip kalau tidak ada icon
        result.add(CategoryModel(title: title, iconPath: iconPath));
      }

      return result;
    } catch (e) {
      print('getHomeCategories error: $e');
      return [];
    }
  }

  /// Untuk filter — semua kategori
  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _supabase
          .from('service_categories')
          .select('id_category, nama')
          .order('id_category', ascending: true);

      return (data as List).map((e) {
        final title = e['nama'].toString();
        return CategoryModel(
          title: title,
          iconPath: _getIconPath(title) ?? '', // fallback kosong
        );
      }).toList();
    } catch (e) {
      print('getCategories error: $e');
      return [];
    }
  }

  String? _getIconPath(String title) {
    final t = title.toLowerCase().trim();
    if (t.contains('website')) return 'assets/images/categories/website_development.png';
    if (t.contains('graphic')) return 'assets/images/categories/graphic_design.png';
    if (t.contains('photo')) return 'assets/images/categories/photography.png';
    if (t.contains('video')) return 'assets/images/categories/video_editing.png';
    if (t.contains('image')) return 'assets/images/categories/image_editing.png';
    if (t.contains('writing') || t.contains('translation')) return 'assets/images/categories/writing_translation.png';
    return null;
  }
  /// =========================
  /// POPULAR SERVICES 
  /// =========================
  Future<List<ServiceModel>> getPopularServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .order('rating_avg', ascending: false)
          .order('total_order', ascending: false)
          .limit(10);

      return (response as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    } catch (e) {
      print('getPopularServices error: $e');
      return [];
    }
  }

  /// =========================
  /// ALL SERVICES 
  /// =========================
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    } catch (e) {
      print('getAllServices error: $e');
      return [];
    }
  }

  /// =========================
  /// SEARCH SERVICES 
  /// =========================
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .ilike('title', '%$query%');

      return (response as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    } catch (e) {
      print('searchServices error: $e');
      return [];
    }
  }
}