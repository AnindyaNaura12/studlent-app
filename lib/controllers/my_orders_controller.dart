import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class MyOrdersController {
  final _supabase = Supabase.instance.client;

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      // Ambil email dari Supabase Auth
      final email = _supabase.auth.currentUser?.email;
      if (email == null) throw Exception('User belum login');

      // Ambil id_user dari tabel users berdasarkan email
      final userData = await _supabase
          .from('users')
          .select('id_user')
          .eq('email', email)
          .maybeSingle();

      if (userData == null) throw Exception('Data user tidak ditemukan');
      final int clientId = userData['id_user'] as int;

      // Fetch orders milik client
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
              admin_fee
            )
          ''')
          .eq('id_client', clientId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetch orders: $e');
      rethrow;
    }
  }

  List<OrderModel> getOrdersByTab(List<OrderModel> allOrders, String tabName) {
    if (tabName == 'All') return allOrders;
    if (tabName == 'Active') {
      const activeStatuses = ['paid', 'diproses', 'hasil_dikirim', 'revisi'];
      return allOrders.where((o) => activeStatuses.contains(o.status)).toList();
    }
    if (tabName == 'Done') {
      return allOrders.where((o) => o.status == 'selesai').toList();
    }
    return [];
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return const Color(0xFFFFA726);
      case 'paid':
      case 'diproses':            return const Color(0xFF42A5F5);
      case 'hasil_dikirim':
      case 'revisi':              return const Color(0xFFAB47BC);
      case 'selesai':             return const Color(0xFF66BB6A);
      case 'dibatalkan':          return const Color(0xFFEF5350);
      default:                    return const Color(0xFF90CAF9);
    }
  }

  String formatDisplayStatus(String status) {
    const map = {
      'menunggu_pembayaran': 'Menunggu Pembayaran',
      'paid':                'Dibayar',
      'diproses':            'Diproses',
      'hasil_dikirim':       'Hasil Dikirim',
      'revisi':              'Revisi',
      'selesai':             'Selesai',
      'dibatalkan':          'Dibatalkan',
    };
    return map[status] ?? status;
  }
}