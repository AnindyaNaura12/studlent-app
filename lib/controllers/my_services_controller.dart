import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/services_model.dart';
import '../models/service_category_model.dart';

class MyServicesController {
  final supabase = Supabase.instance.client;

  List<ServiceModel> services = [];
  List<ServiceCategory> categories = [];

  final List<String> deliveryTimes = [
    '1 day',
    '2 days',
    '3 days',
    '5 days',
    '7 days',
    '14 days',
    '30 days',
  ];

  Future<int?> getCurrentUserId() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null || authUser.email == null) {
        debugPrint('USER BELUM LOGIN');
        return null;
      }

      final userData = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      return userData['id_user'] as int;
    } catch (e) {
      debugPrint('ERROR GET CURRENT USER ID: $e');
      return null;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final data = await supabase
          .from('service_categories')
          .select('id_category, nama')
          .order('id_category', ascending: true);

      debugPrint('RAW CATEGORY DATA: $data');

      categories = (data as List)
          .map((e) => ServiceCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      debugPrint('TOTAL CATEGORY: ${categories.length}');
    } catch (e) {
      categories = [];
      debugPrint('ERROR FETCH CATEGORIES: $e');
    }
  }

  Future<void> fetchServices({String? category}) async {
    try {
      dynamic query = supabase.from('service_detail').select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final data = await query.order('rating_avg', ascending: false);

      services = (data as List)
          .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('ERROR FETCH SERVICES: $e');
      services = [];
    }
  }

  Future<void> fetchMyServices({String? category}) async {
    try {
      final currentUserId = await getCurrentUserId();

      if (currentUserId == null) {
        services = [];
        debugPrint('ID USER TIDAK DITEMUKAN');
        return;
      }

      dynamic query = supabase
          .from('service_detail')
          .select()
          .eq('id_freelancer', currentUserId);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final data = await query.order('rating_avg', ascending: false);

      services = (data as List)
          .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      debugPrint('MY SERVICES LENGTH: ${services.length}');
    } catch (e) {
      debugPrint('ERROR FETCH MY SERVICES: $e');
      services = [];
    }
  }
  Future<List<Map<String, dynamic>>> fetchServicePackages(int idService) async {
    try {
      final data = await supabase
          .from('service_packages')
          .select()
          .eq('id_service', idService)
          .order('id_package', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('ERROR FETCH PACKAGES: $e');
      return [];
    }
  }

  // DITAMBAH: fetch images untuk satu service
  Future<List<String>> fetchServiceImages(int idService) async {
    try {
      final data = await supabase
          .from('service_images')
          .select('image_url')
          .eq('id_service', idService);
      return (data as List)
          .map((e) => e['image_url'] as String)
          .toList();
    } catch (e) {
      debugPrint('ERROR FETCH IMAGES: $e');
      return [];
    }
  }

  Future<void> _replaceServicePackages({
    required int idService,
    String? basicPrice,
    String? basicDeliveryTime,
    String? basicShortDescription,
    String? standardPrice,
    String? standardDeliveryTime,
    String? standardShortDescription,
    String? premiumPrice,
    String? premiumDeliveryTime,
    String? premiumShortDescription,
  }) async {
    await supabase
        .from('service_packages')
        .delete()
        .eq('id_service', idService);

    final packages = [
      {
        'nama': 'basic',
        'harga': _parsePriceToDouble(basicPrice),
        'delivery_time': _parseDeliveryToInt(basicDeliveryTime),
        'deskripsi': basicShortDescription?.trim() ?? '',
      },
      {
        'nama': 'standard',
        'harga': _parsePriceToDouble(standardPrice),
        'delivery_time': _parseDeliveryToInt(standardDeliveryTime),
        'deskripsi': standardShortDescription?.trim() ?? '',
      },
      {
        'nama': 'premium',
        'harga': _parsePriceToDouble(premiumPrice),
        'delivery_time': _parseDeliveryToInt(premiumDeliveryTime),
        'deskripsi': premiumShortDescription?.trim() ?? '',
      },
    ];

    final rows = packages
        .map(
          (pkg) => {
            'id_service': idService,
            'nama': pkg['nama'],
            'harga': pkg['harga'],
            'delivery_time': pkg['delivery_time'],
            'deskripsi': pkg['deskripsi'],
          },
        )
        .toList();

    await supabase.from('service_packages').insert(rows);
  }

  double _parsePriceToDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  int _parseDeliveryToInt(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  Future<ServiceModel?> addService({
    required int freelancerId,
    required int categoryId,
    required String title,
    required String description,
    String? imageUrl,
    List<String>? serviceImages,
    String status = 'pending',
    String? basicPrice,
    String? basicDeliveryTime,
    String? basicShortDescription,
    String? standardPrice,
    String? standardDeliveryTime,
    String? standardShortDescription,
    String? premiumPrice,
    String? premiumDeliveryTime,
    String? premiumShortDescription,
  }) async {
    try {
      final List<String> finalImages = serviceImages ?? [];
      final String? finalThumbnail =
          imageUrl ?? (finalImages.isNotEmpty ? finalImages.first : null);

      final serviceResult = await supabase
          .from('services')
          .insert({
            'id_freelancer': freelancerId,
            'id_category': categoryId,
            'judul': title,
            'deskripsi': description,
            'thumbnail_url': finalThumbnail,
            'status': status,
          })
          .select()
          .single();

      final int idService = serviceResult['id_service'] as int;

      if (finalImages.isNotEmpty) {
        final imageRows = finalImages
            .map((url) => {'id_service': idService, 'image_url': url})
            .toList();

        await supabase.from('service_images').insert(imageRows);
      }

      await _replaceServicePackages(
        idService: idService,
        basicPrice: basicPrice,
        basicDeliveryTime: basicDeliveryTime,
        basicShortDescription: basicShortDescription,
        standardPrice: standardPrice,
        standardDeliveryTime: standardDeliveryTime,
        standardShortDescription: standardShortDescription,
        premiumPrice: premiumPrice,
        premiumDeliveryTime: premiumDeliveryTime,
        premiumShortDescription: premiumShortDescription,
      );

      final detail = await supabase
          .from('service_detail')
          .select()
          .eq('id_service', idService)
          .single();

      final newService = ServiceModel.fromJson(
        Map<String, dynamic>.from(detail),
      );

      services.insert(0, newService);
      return newService;
    } catch (e) {
      debugPrint('ERROR ADD SERVICE: $e');
      return null;
    }
  }

  Future<bool> updateService({
    required int idService,
    int? categoryId,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? serviceImages,
    String? status,
    String? basicPrice,
    String? basicDeliveryTime,
    String? basicShortDescription,
    String? standardPrice,
    String? standardDeliveryTime,
    String? standardShortDescription,
    String? premiumPrice,
    String? premiumDeliveryTime,
    String? premiumShortDescription,
  }) async {
    try {
      final Map<String, dynamic> updatedData = {};

      if (categoryId != null) updatedData['id_category'] = categoryId;
      if (title != null) updatedData['judul'] = title;
      if (description != null) updatedData['deskripsi'] = description;
      if (status != null) updatedData['status'] = status;

      if (serviceImages != null) {
        updatedData['thumbnail_url'] = serviceImages.isNotEmpty
            ? serviceImages.first
            : null;
      } else if (imageUrl != null) {
        updatedData['thumbnail_url'] = imageUrl;
      }

      if (updatedData.isNotEmpty) {
        await supabase
            .from('services')
            .update(updatedData)
            .eq('id_service', idService);
      }

      if (serviceImages != null) {
        await supabase
            .from('service_images')
            .delete()
            .eq('id_service', idService);

        if (serviceImages.isNotEmpty) {
          final imageRows = serviceImages
              .map((url) => {'id_service': idService, 'image_url': url})
              .toList();

          await supabase.from('service_images').insert(imageRows);
        }
      }

      await _replaceServicePackages(
        idService: idService,
        basicPrice: basicPrice,
        basicDeliveryTime: basicDeliveryTime,
        basicShortDescription: basicShortDescription,
        standardPrice: standardPrice,
        standardDeliveryTime: standardDeliveryTime,
        standardShortDescription: standardShortDescription,
        premiumPrice: premiumPrice,
        premiumDeliveryTime: premiumDeliveryTime,
        premiumShortDescription: premiumShortDescription,
      );

      final detail = await supabase
          .from('service_detail')
          .select()
          .eq('id_service', idService)
          .single();

      final updatedService = ServiceModel.fromJson(
        Map<String, dynamic>.from(detail),
      );

      final index = services.indexWhere((s) => s.id == idService.toString());

      if (index != -1) {
        services[index] = updatedService;
      }

      return true;
    } catch (e) {
      debugPrint('ERROR UPDATE SERVICE: $e');
      return false;
    }
  }

  Future<bool> deleteService(int idService) async {
    try {
      await supabase.from('services').delete().eq('id_service', idService);

      services.removeWhere((s) => s.id == idService.toString());
      return true;
    } catch (e) {
      debugPrint('ERROR DELETE SERVICE: $e');
      return false;
    }
  }

  ServiceCategory? findCategoryById(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int? findCategoryIdByName(String name) {
    try {
      return categories.firstWhere((c) => c.name == name).id;
    } catch (_) {
      return null;
    }
  }
}
