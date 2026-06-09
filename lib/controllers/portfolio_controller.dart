import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // DITAMBAH: untuk pick file sertifikat
import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioController {
  final supabase = Supabase.instance.client;

  // DIUBAH: dari categories ke jobdesks
  final List<String> jobdesks = [
    'Frontend Developer',
    'Backend Developer',
    'UI/UX Designer',
    'Fullstack Developer',
    'Mobile Developer',
    'Graphic Designer',
    'Video Editor',
    'Photographer',
    'Content Writer',
    'Translator',
    'Data Analyst',
    'DevOps Engineer',
    'Ilustrator',
    'Motion Graphic',
    'Social Media Manager',
  ];

  Future<int?> _getCurrentUserId() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;
    final user = await supabase
        .from('users')
        .select('id_user')
        .eq('email', authUser.email!)
        .single();
    return user['id_user'] as int?;
  }

  Future<List<Map<String, dynamic>>> getPortfolios() async {
    try {
      final idUser = await _getCurrentUserId();
      if (idUser == null) return [];

      final result = await supabase
          .from('portfolios')
          .select()
          .eq('id_user', idUser)
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

      return supabase.storage.from('Portofolios').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('uploadPortfolioImage error: $e');
      return null;
    }
  }

  Future<bool> addPortfolio({
    required String title,
    required String description,
    required String jobdesk, // DIUBAH: dari category ke jobdesk
    String? imageUrl,
  }) async {
    try {
      final idUser = await _getCurrentUserId();
      if (idUser == null) return false;

      await supabase.from('portfolios').insert({
        'id_user': idUser,
        'judul': title,
        'deskripsi': description,
        'jobdesk': jobdesk, // DIUBAH
        'category':
            jobdesk, // DITAMBAH: isi juga category untuk backward compat
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
    required String jobdesk, // DIUBAH: dari category ke jobdesk
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'judul': title,
        'deskripsi': description,
        'jobdesk': jobdesk, // DIUBAH
        'category': jobdesk, // DITAMBAH: backward compat
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

  // ─── CERTIFICATE METHODS (DITAMBAH) ───────────────────────

  Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      final idUser = await _getCurrentUserId();
      if (idUser == null) return [];

      final result = await supabase
          .from('freelancer_certificates')
          .select()
          .eq('id_user', idUser)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('getCertificates error: $e');
      return [];
    }
  }

  // Upload sertifikat (PDF / gambar) ke storage
  Future<Map<String, String>?> uploadCertificate() async {
    debugPrint('=== uploadCertificate DIPANGGIL ==='); // TAMBAH PALING ATAS

    try {
      // Cek bucket dulu sebelum pick file
      final buckets = await supabase.storage.listBuckets();
      debugPrint(
        'BUCKETS: ${buckets.map((b) => '${b.id}|${b.name}').toList()}',
      );

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('FILE PICKER: user cancel atau tidak ada file');
        return null;
      }

      final file = result.files.first;
      debugPrint(
        'FILE DIPILIH: ${file.name}, ext: ${file.extension}, bytes: ${file.bytes?.length}',
      );

      final bytes = file.bytes;
      if (bytes == null) {
        debugPrint('BYTES NULL');
        return null;
      }

      final ext = file.extension?.toLowerCase() ?? 'pdf';
      final fileName = 'cert_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mimeType = ext == 'pdf' ? 'application/pdf' : 'image/$ext';

      debugPrint('UPLOAD KE BUCKET: certificates, fileName: $fileName');

      await supabase.storage
          .from('certificates')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mimeType),
          );

      debugPrint('UPLOAD SUKSES');

      final url = supabase.storage.from('certificates').getPublicUrl(fileName);
      debugPrint('URL: $url');

      return {'url': url, 'name': file.name};
    } catch (e) {
      debugPrint('uploadCertificate error DETAIL: $e');
      return null;
    }
  }

  Future<bool> addCertificate({
    required String fileUrl,
    required String fileName,
    required int idUser,
  }) async {
    try {
      await supabase.from('freelancer_certificates').insert({
        'id_user': idUser,
        'file_url': fileUrl,
        'file_name': fileName,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('addCertificate error: $e');
      return false;
    }
  }

  Future<void> deleteCertificate(int idCert, {required int idUser}) async {
    try {
      await supabase
          .from('freelancer_certificates')
          .delete()
          .eq('id_certificate', idCert)
          .eq('id_user', idUser);
    } catch (e) {
      debugPrint('deleteCertificate error: $e');
    }
  }
}
