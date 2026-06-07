// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import 'home_pages.dart';
import 'my_orders_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int idOrder;
  final double amount;

  const PaymentSuccessPage({
    super.key,
    required this.idOrder,
    required this.amount,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isLoading = true;
  String _metode = '-';
  String _serviceName = '-';
  String _date = '';
  double _adminFee = 2500;
  String _orderStatus = '-';
  String _paymentStatus = 'pending';
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.laravelBaseUrl}/orders/${widget.idOrder}/status'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          _metode = _formatMetode(data['payment_method']?.toString() ?? '-');
          _serviceName = data['service_name']?.toString() ?? '-';
          _adminFee = (data['admin_fee'] as num?)?.toDouble() ?? 2500;
          _orderStatus = data['status']?.toString() ?? '-';
          _paymentStatus = data['payment_status']?.toString() ?? 'pending';
          _isPaid = data['is_paid'] == true;
          _date = data['created_at'] != null
              ? _formatDate(data['created_at'].toString())
              : _formattedToday();
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data order');
      }
    } catch (e) {
      debugPrint('Error fetching payment data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatMetode(String metode) {
    const map = {
      'bca_va': 'BCA Virtual Account',
      'bni_va': 'BNI Virtual Account',
      'bri_va': 'BRI Virtual Account',
      'echannel': 'Mandiri Virtual Account',
      'gopay': 'GoPay',
      'shopeepay': 'ShopeePay',
      'dana': 'DANA',
      'ovo': 'OVO',
      'bank_transfer': 'Bank Transfer',
      'credit_card': 'Kartu Kredit',
    };
    return map[metode] ?? metode;
  }

  String _statusLabel() {
    if (_paymentStatus == 'expired') return 'Pembayaran Kedaluwarsa';
    if (_paymentStatus == 'failed') return 'Pembayaran Gagal';
    if (_paymentStatus == 'challenge') return 'Menunggu Verifikasi';
    return 'Pembayaran Berhasil';
  }

  Color _statusColor() {
    const Color primaryColor = Color(0xFFFFA726);
    if (_paymentStatus == 'expired' || _paymentStatus == 'failed') {
      return Colors.red;
    }
    if (_paymentStatus == 'challenge') {
      return Colors.orange;
    }
    return primaryColor;
  }

  String _formatOrderStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'pembayaran_gagal':
        return 'Pembayaran Gagal';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFFA726);
    const Color darkColor = Color(0xFF1A1A2E);
    const Color greyColor = Color(0xFF9098B1);
    const Color bgColor = Color(0xFFF5F5F5);

    final double packagePrice = widget.amount - _adminFee;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 48),
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 82,
                                      height: 82,
                                      decoration: const BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Color(0xFFFFD54F),
                                            Color(0xFFFFA726),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Payment Successful',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: darkColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Berhasil membayar Rp${_fmt(widget.amount)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: greyColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        20,
                                        20,
                                        20,
                                        16,
                                      ),
                                      child: Text(
                                        'Detail Pembayaran',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: darkColor,
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFF0F0F0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        16,
                                        20,
                                        20,
                                      ),
                                      child: Column(
                                        children: [
                                          _buildRow(
                                            'Transaction ID',
                                            '#${widget.idOrder}',
                                          ),
                                          _buildRow(
                                            'Tanggal',
                                            _date.isNotEmpty
                                                ? _date
                                                : _formattedToday(),
                                          ),
                                          _buildRow('Metode Bayar', _metode),
                                          _buildRow('Jasa', _serviceName),
                                          _buildRow(
                                            'Harga Paket',
                                            'Rp${_fmt(packagePrice)}',
                                          ),
                                          _buildRow(
                                            'Biaya Admin',
                                            'Rp${_fmt(_adminFee)}',
                                          ),
                                          _buildRow(
                                            'Total',
                                            'Rp${_fmt(widget.amount)}',
                                            valueBold: true,
                                          ),
                                          _buildRow(
                                            'Status',
                                            _statusLabel(),
                                            valueColor: _statusColor(),
                                            valueBold: true,
                                          ),
                                          _buildRow(
                                            'Order Status',
                                            _formatOrderStatus(_orderStatus),
                                            valueBold: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _goHome(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Back Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => _goToOrders(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryColor),
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Lihat Order Saya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void _goToOrders(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyOrdersPage()),
      (route) => false,
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    const Color greyColor = Color(0xFF9098B1);
    const Color darkColor = Color(0xFF1A1A2E);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: greyColor)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? darkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    const m = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${now.day} ${m[now.month - 1]} ${now.year}';
  }

  String _formatDate(String s) {
    try {
      final d = DateTime.parse(s);
      const m = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return s;
    }
  }

  String _fmt(double price) {
    final s = price.toInt().toString();
    final b = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) b.write('.');
      b.write(s[i]);
      c++;
    }
    return b.toString().split('').reversed.join();
  }
}
