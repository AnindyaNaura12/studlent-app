// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config.dart';
import '../../models/order_model.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isCompleting = false;

  Future<void> _handleCompleteOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesaikan Pesanan?'),
        content: const Text(
          'Dengan menekan "Ya, Selesai", dana akan langsung dicairkan ke freelancer. '
          'Pastikan kamu sudah menerima hasil pekerjaan dengan baik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Ya, Selesai',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isCompleting = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.laravelBaseUrl}/payment/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_order': int.tryParse(widget.order.id) ?? 0}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double freelancerReceive =
            (data['freelancer_receive'] as num?)?.toDouble() ?? 0;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      color: Color(0xFF4CAF50), size: 44),
                ),
                const SizedBox(height: 16),
                const Text('Pesanan Selesai!',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Dana sebesar Rp ${_formatPrice(freelancerReceive)} '
                  'berhasil dicairkan ke freelancer.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // tutup dialog
                      Navigator.pop(context); // kembali ke MyOrdersPage
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Kembali ke My Orders',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal menyelesaikan pesanan');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  String _formatPrice(double price) {
    final s   = price.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final order      = widget.order;
    final isPaid     = order.status != 'menunggu_pembayaran';
    final isActive   = ['paid', 'diproses', 'hasil_dikirim', 'revisi']
        .contains(order.status);
    final isDone     = order.status == 'selesai';
    final isNetworkAvatar = order.freelancerAvatar.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          // TOP BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 26),
              ),
              const SizedBox(width: 12),
              Image.asset('assets/images/logo_studlent.png', height: 40),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                const SizedBox(height: 8),

                // ORDER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Freelancer info
                    Row(children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: isNetworkAvatar
                            ? NetworkImage(order.freelancerAvatar)
                                as ImageProvider
                            : null,
                        child: !isNetworkAvatar
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.freelancerName,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(order.serviceName,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      )),
                      Text(order.price,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 16),

                    // Status badge
                    Row(children: [
                      const Text('Status: ',
                          style: TextStyle(
                              fontSize: 13, color: Colors.black54)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_statusLabel(order.status),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // Deadline
                    RichText(
                        text: TextSpan(
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54),
                      children: [
                        const TextSpan(text: 'Deadline: '),
                        TextSpan(
                            text: order.deadline,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    )),
                    const SizedBox(height: 12),

                    // Catatan
                    if (order.note.isNotEmpty) ...[
                      RichText(
                          text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black),
                        children: [
                          const TextSpan(
                              text: 'Catatan:\n',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: order.note),
                        ],
                      )),
                      const SizedBox(height: 12),
                    ],

                    // Price detail
                    const Divider(),
                    const SizedBox(height: 8),
                    _priceRow('Harga Paket',
                        'Rp ${_formatPrice(order.amount - order.adminFee)}'),
                    const SizedBox(height: 4),
                    _priceRow('Biaya Admin',
                        'Rp ${_formatPrice(order.adminFee)}'),
                    const SizedBox(height: 4),
                    _priceRow('Total', order.price, bold: true),
                    const SizedBox(height: 20),

                    // Tombol Chat Freelancer
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: navigate ke chat page
                        },
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: Color(0xFFFFA726)),
                        label: const Text('Chat Freelancer',
                            style: TextStyle(
                                color: Color(0xFFFFA726),
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFA726)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Pesanan Selesai — hanya muncul saat status aktif
                    if (isActive) ...[
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed:
                              _isCompleting ? null : _handleCompleteOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            disabledBackgroundColor:
                                const Color(0xFFA5D6A7),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: _isCompleting
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('Pesanan Selesai',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],

                    // Info kalau sudah selesai
                    if (isDone) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(children: [
                          Icon(Icons.check_circle,
                              color: Color(0xFF4CAF50), size: 20),
                          SizedBox(width: 8),
                          Text('Pesanan sudah selesai',
                              style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: bold ? Colors.black : Colors.black54,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]);

  Color _statusColor(String status) {
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

  String _statusLabel(String status) {
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