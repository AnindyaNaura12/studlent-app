import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/services_model.dart';
import '../models/category_model.dart';

class HomeController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// =========================
  /// KATEGORI 
  /// =========================
  List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        title: 'Website Development',
        iconPath: 'assets/images/categories/website_development.png',
      ),
      CategoryModel(
        title: 'Graphic Design',
        iconPath: 'assets/images/categories/graphic_design.png',
      ),
      CategoryModel(
        title: 'Photography',
        iconPath: 'assets/images/categories/photography.png',
      ),
      CategoryModel(
        title: 'Video Editing',
        iconPath: 'assets/images/categories/video_editing.png',
      ),
      CategoryModel(
        title: 'Image Editing',
        iconPath: 'assets/images/categories/image_editing.png',
      ),
      CategoryModel(
        title: 'Writing & Translation',
        iconPath: 'assets/images/categories/writing_translation.png',
      ),
    ];
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