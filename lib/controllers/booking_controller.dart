import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingController {
  final _supabase = Supabase.instance.client;
  String selectedFilter = 'All';

  Future<List<Booking>> fetchBookings() async {
    try {
      // Ambil email dari Supabase Auth
      final email = _supabase.auth.currentUser?.email;
      if (email == null) throw Exception('User belum login');

      // Ambil id_user dari tabel users
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
            id_freelancer,
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
              amount
            )
          ''')
          .eq('id_client', clientId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetch bookings: $e');
      rethrow;
    }
  }

  List<Booking> getFiltered(List<Booking> all) {
    if (selectedFilter == 'Active') {
      const active = ['paid', 'diproses', 'hasil_dikirim', 'revisi'];
      return all.where((b) => active.contains(b.status)).toList();
    }
    if (selectedFilter == 'Done') {
      return all.where((b) => b.status == 'selesai').toList();
    }
    return all;
  }

  void setFilter(String filter) {
    selectedFilter = filter;
  }

  String formatStatus(String status) {
    const map = {
      'menunggu_pembayaran': 'Menunggu Bayar',
      'paid':                'Dibayar',
      'diproses':            'Diproses',
      'hasil_dikirim':       'Hasil Dikirim',
      'revisi':              'Revisi',
      'selesai':             'Selesai',
      'dibatalkan':          'Dibatalkan',
    };
    return map[status] ?? status;
  }

  Color statusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return Colors.orange;
      case 'paid':
      case 'diproses':            return Colors.blue;
      case 'hasil_dikirim':
      case 'revisi':              return Colors.purple;
      case 'selesai':             return Colors.green;
      case 'dibatalkan':          return Colors.red;
      default:                    return Colors.grey;
    }
  }
}