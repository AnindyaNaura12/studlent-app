import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioController {
  final supabase = Supabase.instance.client;

  final List<String> categories = [
    'Website Development',
    'Graphic Design',
    'Photography',
    'Video Editing',
    'Image Editing',
    'Writing & Translation',
  ];

  Future<List<Map<String, dynamic>>> getPortfolios() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return [];
      }

      final user = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      final result = await supabase
          .from('portfolios')
          .select()
          .eq('id_user', user['id_user'])
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('getPortfolios error: $e');
      return [];
    }
  }

  Future<String?> uploadPortfolioImage() async {
    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      final fileExt = picked.name.split('.').last.toLowerCase();
      final fileName =
          'portfolio_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage
          .from('Portofolios')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExt',
            ),
          );

      final imageUrl = supabase.storage
          .from('Portofolios')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      debugPrint('uploadPortfolioImage error: $e');
      return null;
    }
  }

  Future<bool> addPortfolio({
    required String title,
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return false;
      }

      final user = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      await supabase.from('portfolios').insert({
        'id_user': user['id_user'],
        'judul': title,
        'deskripsi': description,
        'category': category,
        'file_url': imageUrl,
        'thumbnail_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('addPortfolio error: $e');
      return false;
    }
  }

  Future<bool> updatePortfolio({
    required int idPortfolio,
    required String title,
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'judul': title,
        'deskripsi': description,
        'category': category,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (imageUrl != null) {
        updates['thumbnail_url'] = imageUrl;
        updates['file_url'] = imageUrl;
      }

      await supabase
          .from('portfolios')
          .update(updates)
          .eq('id_portfolio', idPortfolio);

      return true;
    } catch (e) {
      debugPrint('updatePortfolio error: $e');
      return false;
    }
  }

  Future<bool> deletePortfolio(int idPortfolio) async {
    try {
      await supabase
          .from('portfolios')
          .delete()
          .eq('id_portfolio', idPortfolio);

      return true;
    } catch (e) {
      debugPrint('deletePortfolio error: $e');
      return false;
    }
  }
}
