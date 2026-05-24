// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late String _selectedStatus;
  bool _isCompleting = false;

  // Ganti dengan URL Laravel kamu
  static const String _baseUrl = 'https://YOUR-LARAVEL-URL.com/api';

  final List<String> _statusOptions = [
    'In Progress',
    'Pending',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF90CAF9);
      case 'Pending':
        return const Color(0xFFEC407A);
      case 'Completed':
        return const Color(0xFF66BB6A);
      case 'Cancelled':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF90CAF9);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // COMPLETE ORDER → release escrow → dana cair ke freelancer
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleCompleteOrder() async {
    // Konfirmasi dulu sebelum eksekusi
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
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text(
              'Ya, Selesai',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCompleting = true);

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final token   = session?.accessToken ?? '';

      final response = await http.post(
        Uri.parse('$_baseUrl/payment/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type' : 'application/json',
          'Accept'       : 'application/json',
        },
        body: jsonEncode({'id_order': int.tryParse(widget.order.id) ?? 0}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double freelancerReceive =
            (data['freelancer_receive'] as num).toDouble();

        // Tampil dialog sukses
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width  : 70,
                  height : 70,
                  decoration: const BoxDecoration(
                    color : Color(0xFFE8F5E9),
                    shape : BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color : Color(0xFF4CAF50),
                    size  : 44,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pesanan Selesai!',
                  style: TextStyle(
                    fontSize   : 18,
                    fontWeight : FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dana sebesar Rp ${_formatPrice(freelancerReceive)} '
                  'berhasil dicairkan ke freelancer.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize : 13,
                    color    : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width  : double.infinity,
                  height : 48,
                  child  : ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // tutup dialog
                      Navigator.pop(context); // kembali ke MyOrdersPage
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke My Orders',
                      style: TextStyle(
                        color      : Colors.white,
                        fontWeight : FontWeight.bold,
                      ),
                    ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content         : Text('❌ ${e.toString()}'),
          backgroundColor : Colors.red,
          duration        : const Duration(seconds: 3),
        ),
      );
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

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ── tidak diubah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Image.asset('assets/images/logo_studlent.png', height: 40),
                ],
              ),
            ),

            // ── CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── WHITE CARD ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color    : Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset   : const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Freelancer info + price ── tidak diubah
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  order.freelancerAvatar,
                                ),
                                onBackgroundImageError: (_, __) {},
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.freelancerName,
                                      style: const TextStyle(
                                        fontSize  : 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      order.serviceName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color   : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                order.price,
                                style: const TextStyle(
                                  fontSize  : 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Note ── tidak diubah
                          if (order.note.isNotEmpty) ...[
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color   : Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text : 'Note:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: order.note),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ── Deadline ── tidak diubah
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color   : Colors.black54,
                              ),
                              children: [
                                const TextSpan(text: 'Deadline: '),
                                TextSpan(
                                  text : order.deadline,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color     : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Upload Work ── tidak diubah
                          const Text(
                            'Upload Work',
                            style: TextStyle(
                              fontSize  : 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // TODO: file picker
                            },
                            child: Container(
                              width  : double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color        : const Color(0xFFEEEEFF),
                                borderRadius : BorderRadius.circular(12),
                                border       : Border.all(
                                  color: const Color(0xFFBBBBEE),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_rounded,
                                      color: Colors.black87, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Upload Work',
                                    style: TextStyle(
                                      fontSize  : 15,
                                      fontWeight: FontWeight.bold,
                                      color     : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Update Progress ── tidak diubah
                          const Text(
                            'Update Progress',
                            style: TextStyle(
                              fontSize  : 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical  : 4,
                            ),
                            decoration: BoxDecoration(
                              color        : Colors.white,
                              borderRadius : BorderRadius.circular(12),
                              border       : Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value     : _selectedStatus,
                                icon      : const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black54,
                                ),
                                selectedItemBuilder: (context) {
                                  return _statusOptions.map((status) {
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical  : 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color       : _getStatusColor(status),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color     : Colors.white,
                                              fontSize  : 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                                items: _statusOptions.map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedStatus = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Chat with Client ── tidak diubah
                          SizedBox(
                            width : double.infinity,
                            height: 52,
                            child : ElevatedButton(
                              onPressed: () {
                                // TODO: navigasi ke chat
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB74D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Chat with Client',
                                style: TextStyle(
                                  color     : Colors.white,
                                  fontSize  : 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Save Changes ── tidak diubah
                          SizedBox(
                            width : double.infinity,
                            height: 52,
                            child : ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Progress berhasil disimpan!'),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color     : Colors.white,
                                  fontSize  : 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── BARU: Pesanan Selesai ──────────────────────
                          // Hanya tampil jika status in_progress / completed
                          if (order.status == 'In Progress' ||
                              order.status == 'in_progress') ...[
                            SizedBox(
                              width : double.infinity,
                              height: 52,
                              child : ElevatedButton(
                                onPressed: _isCompleting
                                    ? null
                                    : _handleCompleteOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor        : const Color(0xFF4CAF50),
                                  disabledBackgroundColor: const Color(0xFFA5D6A7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isCompleting
                                    ? const SizedBox(
                                        width : 24,
                                        height: 24,
                                        child : CircularProgressIndicator(
                                          color      : Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Pesanan Selesai',
                                        style: TextStyle(
                                          color     : Colors.white,
                                          fontSize  : 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}