import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class MyOrdersController {
  final _supabase = Supabase.instance.client;

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final email = _supabase.auth.currentUser?.email;
      if (email == null) {
        throw Exception('User belum login');
      }

      final userData = await _supabase
          .from('users')
          .select('id_user')
          .eq('email', email)
          .maybeSingle();

      if (userData == null) {
        throw Exception('Data user tidak ditemukan');
      }

      final int clientId = userData['id_user'] as int;

      final response = await _supabase
          .from('orders')
          .select('''
            id_order,
            status,
            detail_pesanan,
            catatan,
            deadline,
            created_at,
            freelancer:id_freelancer (
              nama,
              foto
            ),
            service:id_service (
              judul
            ),
            payment:payments (
              amount,
              admin_fee,
              status,
              metode
            )
          ''')
          .eq('id_client', clientId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;

      final normalized = data.map((item) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(item);

        final rawStatus = (json['status'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        json['status'] = rawStatus;

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
    } catch (e) {
      debugPrint('Error fetch orders: $e');
      rethrow;
    }
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
}
