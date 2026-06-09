import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import 'dart:io';

class MyOrdersController {
  final _supabase = Supabase.instance.client;

  Future<int> _getCurrentUserId({
    String notLoggedInMessage = 'User belum login',
    String notFoundMessage = 'Data user tidak ditemukan',
  }) async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) {
      throw Exception(notLoggedInMessage);
    }

    final userData = await _supabase
        .from('users')
        .select('id_user')
        .eq('email', email)
        .maybeSingle();

    if (userData == null) {
      throw Exception(notFoundMessage);
    }

    return userData['id_user'] as int;
  }

  Future<List<OrderModel>> fetchUserOrders() async {
    return fetchClientOrders();
  }

  Future<List<OrderModel>> fetchClientOrders() async {
    try {
      final clientId = await _getCurrentUserId(
        notLoggedInMessage: 'Client belum login',
        notFoundMessage: 'Data client tidak ditemukan',
      );

      final response = await _supabase
          .from('orders')
          .select('''
            id_order,
            id_freelancer,
            id_service,
            id_client,
            status,
            detail_pesanan,
            catatan,
            deadline,
            created_at,
            freelancer:id_freelancer(
              nama,
              foto
            ),
            service:id_service(
              id_service,
              judul,
              thumbnail_url,
              service_images(
                id_image,
                image_url
              )
            ),
            payment:payments(
              amount,
              admin_fee,
              status,
              metode,
              payment_url
            )
          ''')
          .eq('id_client', clientId)
          .order('created_at', ascending: false);

      return _mapOrders(response);
    } catch (e) {
      debugPrint('Error fetch client orders: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> fetchFreelancerOrders() async {
    try {
      final freelancerId = await _getCurrentUserId(
        notLoggedInMessage: 'Freelancer belum login',
        notFoundMessage: 'Data freelancer tidak ditemukan',
      );

      final response = await _supabase
          .from('orders')
          .select('''
            id_order,
            id_freelancer,
            id_service,
            id_client,
            status,
            detail_pesanan,
            catatan,
            deadline,
            created_at,
            freelancer:id_freelancer(
              nama,
              foto
            ),
            service:id_service(
              id_service,
              judul,
              thumbnail_url,
              service_images(
                id_image,
                image_url
              )
            ),
            payment:payments(
              amount,
              admin_fee,
              status,
              metode,
              payment_url
            )
          ''')
          .eq('id_freelancer', freelancerId)
          .order('created_at', ascending: false);

      return _mapOrders(response);
    } catch (e) {
      debugPrint('Error fetch freelancer orders: $e');
      rethrow;
    }
  }

  List<OrderModel> _mapOrders(dynamic response) {
    final List<dynamic> data = response;

    final normalized = data.map((item) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(item);

      json['status'] = (json['status'] ?? '').toString().trim().toLowerCase();

      final freelancerRaw = json['freelancer'];
      if (freelancerRaw is Map) {
        json['freelancer'] = Map<String, dynamic>.from(freelancerRaw);
      } else {
        json['freelancer'] = <String, dynamic>{};
      }

      final serviceRaw = json['service'];
      if (serviceRaw is Map) {
        final serviceMap = Map<String, dynamic>.from(serviceRaw);

        final serviceImagesRaw = serviceMap['service_images'];
        if (serviceImagesRaw is List) {
          serviceMap['service_images'] = serviceImagesRaw
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          serviceMap['service_images'] = [];
        }

        json['service'] = serviceMap;
      } else {
        json['service'] = <String, dynamic>{'service_images': []};
      }

      final paymentRaw = json['payment'];
      if (paymentRaw is List) {
        json['payment'] = paymentRaw.isNotEmpty
            ? Map<String, dynamic>.from(paymentRaw.first)
            : null;
      } else if (paymentRaw is Map) {
        json['payment'] = Map<String, dynamic>.from(paymentRaw);
      } else {
        json['payment'] = null;
      }

      return json;
    }).toList();

    return normalized.map((json) => OrderModel.fromJson(json)).toList();
  }

  List<OrderModel> getOrdersByTab(List<OrderModel> allOrders, String tabName) {
    if (tabName == 'All') return allOrders;

    if (tabName == 'Active') {
      const activeStatuses = ['diproses', 'hasil_dikirim', 'revisi', 'paid'];

      return allOrders.where((o) {
        final status = o.status.trim().toLowerCase();
        return activeStatuses.contains(status);
      }).toList();
    }

    if (tabName == 'Done') {
      return allOrders.where((o) {
        final status = o.status.trim().toLowerCase();
        return status == 'selesai';
      }).toList();
    }

    return [];
  }

  Color getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'menunggu_pembayaran':
      case 'pending':
        return const Color(0xFFFFA726);

      case 'paid':
      case 'diproses':
        return const Color(0xFF42A5F5);

      case 'hasil_dikirim':
      case 'revisi':
        return const Color(0xFFAB47BC);

      case 'selesai':
        return const Color(0xFF66BB6A);

      case 'dibatalkan':
      case 'pembayaran_gagal':
      case 'failed':
      case 'expired':
        return const Color(0xFFEF5350);

      default:
        return const Color(0xFF90CAF9);
    }
  }

  String formatDisplayStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Dibayar';
      case 'diproses':
        return 'Diproses';
      case 'hasil_dikirim':
        return 'Hasil Dikirim';
      case 'revisi':
        return 'Revisi';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'pembayaran_gagal':
      case 'failed':
        return 'Pembayaran Gagal';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  Future<int> requestRevision({
    required int orderId,
    required int currentRevisionCount,
  }) async {
    const int maxRevision = 3;

    if (currentRevisionCount >= maxRevision) {
      throw Exception('Batas maksimal revisi ($maxRevision kali) sudah tercapai.');
    }

    final newCount = currentRevisionCount + 1;

    await _supabase
        .from('orders')
        .update({
          'revision_count': newCount,
          'status': 'revisi',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_order', orderId);

    return newCount;
  }

  Future<String> submitResultWithRevisionCheck({
  required int orderId,
  required String resultFileUrl,
  required int currentRevisionCount,
}) async {
  const int maxRevision = 3;

  // Jika ini adalah pengiriman setelah revisi ke-3, langsung selesai
  final String newStatus =
      currentRevisionCount >= maxRevision ? 'selesai' : 'hasil_dikirim';

  // Insert ke tabel deliverables
  await _supabase.from('deliverables').insert({
    'id_order': orderId,
    'file_url': resultFileUrl,
    'catatan': newStatus == 'selesai'
        ? 'Hasil kerja final (revisi ke-$currentRevisionCount)'
        : 'Hasil kerja freelancer',
  });

  // Update status order
  await _supabase
      .from('orders')
      .update({
        'status': newStatus,
        'result_file_url': resultFileUrl,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id_order', orderId);

  return newStatus;
  }
  
  Future<void> submitRequestRevision({
    required int orderId,
    required int currentRevisionCount,
    required String revisionNote,
    required List<File> attachmentFiles,
    required List<String> attachmentNames,
  }) async {
    const int maxRevision = 3;

    if (currentRevisionCount >= maxRevision) {
      throw Exception(
        'Batas maksimal revisi ($maxRevision kali) sudah tercapai.',
      );
    }

    final newCount = currentRevisionCount + 1;

    String? uploadedFileUrl;
    if (attachmentFiles.isNotEmpty) {
      final firstFile = attachmentFiles.first;
      final firstName = attachmentNames.isNotEmpty
          ? attachmentNames.first
          : 'revision_file';
      final uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_$firstName';
      final storagePath = 'revision_files/$orderId/$uniqueName';

      final bytes = await firstFile.readAsBytes();

      await _supabase.storage
          .from('deliverables')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'application/octet-stream',
              upsert: false,
            ),
          );

      uploadedFileUrl = _supabase.storage
          .from('deliverables')
          .getPublicUrl(storagePath);
    }

    await _supabase
        .from('orders')
        .update({
          'revision_count': newCount,
          'status': 'revisi',
          'revision_note':
              revisionNote.trim().isEmpty ? null : revisionNote.trim(),
          'revision_file_url': uploadedFileUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_order', orderId);
  }
}
