import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class MyOrdersController {
  final _supabase = Supabase.instance.client;

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      final response = await _supabase
          .from('orders')
          .select('''
            *,
            freelancers:id_freelancer ( name, avatar_url ),
            services:id_service ( name, price, title )
          ''')
          .eq('id_client', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetch orders: $e');
      rethrow;
    }
  }

  List<OrderModel> getOrdersByTab(List<OrderModel> allOrders, String tabName) {
    if (tabName == 'All') {
      return allOrders;
    } else if (tabName == 'Active') {
      const activeStatuses = ['paid', 'diproses', 'hasil_dikirim', 'revisi'];
      return allOrders.where((o) => activeStatuses.contains(o.status)).toList();
    } else if (tabName == 'Done') {
      return allOrders.where((o) => o.status == 'selesai').toList();
    }
    return [];
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran':
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
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF90CAF9);
    }
  }

  String formatDisplayStatus(String status) {
    if (status.isEmpty) return '';
    return status
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
