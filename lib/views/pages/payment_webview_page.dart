// lib/views/pages/payment_webview_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config.dart';
import 'payment_success_page.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final int orderId;
  final double amount;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.amount,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  final _supabase = Supabase.instance.client;
  bool _paymentDone = false;
  bool _isChecking = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _openPaymentUrl();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Buka Midtrans Snap di browser/tab baru
  Future<void> _openPaymentUrl() async {
    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showSnack('Tidak bisa membuka halaman pembayaran');
      }
    }
  }

  // Polling tiap 5 detik cek status order
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_paymentDone || !mounted) return;
      await _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final res = await http.get(
        Uri.parse('${Config.laravelBaseUrl}/orders/${widget.orderId}/status'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['is_paid'] == true) {
          _onSuccess();
        } else if (data['payment_status'] == 'failed' ||
            data['payment_status'] == 'expired') {
          _onFailed();
        }
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _updateSupabase(String paymentStatus, String orderStatus) async {
    try {
      await _supabase
          .from('payments')
          .update({
            'status': paymentStatus,
            'tanggal_bayar': DateTime.now().toIso8601String(),
          })
          .eq('id_order', widget.orderId);

      await _supabase
          .from('orders')
          .update({'status': orderStatus})
          .eq('id_order', widget.orderId);
    } catch (e) {
      debugPrint('Supabase update error: $e');
    }
  }

  void _onSuccess() {
    if (_paymentDone) return;
    _paymentDone = true;
    _pollingTimer?.cancel();
    if (!mounted) return;

    _updateSupabase('paid', 'diproses').then((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            idOrder: widget.orderId,
            amount: widget.amount,
          ),
        ),
        (route) => route.isFirst,
      );
    });
  }

  void _onFailed() {
    if (_paymentDone) return;
    _paymentDone = true;
    _pollingTimer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text('Pembayaran Gagal'),
        ]),
        content: const Text(
            'Transaksi dibatalkan atau kadaluarsa.\nSilakan coba lagi.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726)),
            child: const Text('Kembali',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Menunggu Pembayaran',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasi loading
              const CircularProgressIndicator(color: Color(0xFFFFA726)),
              const SizedBox(height: 32),
              const Text(
                'Halaman pembayaran sudah dibuka',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Selesaikan pembayaran di tab/halaman Midtrans yang terbuka. Halaman ini akan otomatis update setelah pembayaran berhasil.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Tombol buka ulang kalau tab tertutup
              OutlinedButton.icon(
                onPressed: _openPaymentUrl,
                icon: const Icon(Icons.open_in_new, color: Color(0xFFFFA726)),
                label: const Text('Buka Ulang Halaman Bayar',
                    style: TextStyle(color: Color(0xFFFFA726))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFA726)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol cek manual
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkStatus,
                icon: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.refresh, color: Colors.black),
                label: Text(
                    _isChecking ? 'Mengecek...' : 'Cek Status Pembayaran',
                    style: const TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}