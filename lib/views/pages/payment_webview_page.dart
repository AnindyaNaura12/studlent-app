import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'my_orders_page.dart';

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
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _paymentDone = false;
  Timer? _pollingTimer;

  // Ganti dengan URL Laravel kamu
  static const String _baseUrl = 'http://192.168.1.x:8000/api';

  @override
  void initState() {
    super.initState();
    _initWebView();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // INIT WEBVIEW
  // ─────────────────────────────────────────────────────────────
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url;

            // Midtrans redirect ke URL ini saat transaksi selesai
            if (url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture')) {
              _onPaymentSuccess();
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=deny') ||
                url.contains('transaction_status=expire')) {
              _onPaymentFailed();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // ─────────────────────────────────────────────────────────────
  // POLLING — cek status ke Laravel tiap 4 detik
  // backup kalau redirect URL tidak tertangkap WebView
  // ─────────────────────────────────────────────────────────────
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_paymentDone) return;
      await _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final token   = session?.accessToken ?? '';

      final response = await http.get(
        Uri.parse('$_baseUrl/orders/${widget.orderId}/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept'       : 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['payment_status'] == 'paid') {
          _onPaymentSuccess();
        } else if (data['payment_status'] == 'failed') {
          _onPaymentFailed();
        }
      }
    } catch (_) {
      // Abaikan error polling, coba lagi di iterasi berikut
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HANDLER SUKSES & GAGAL
  // ─────────────────────────────────────────────────────────────
  void _onPaymentSuccess() {
    if (_paymentDone) return;
    _paymentDone = true;
    _pollingTimer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentSuccessDialog(
        amount: widget.amount,
        onClose: () {
          Navigator.of(context).pop(); // tutup dialog
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MyOrdersPage()),
            (route) => route.isFirst,
          );
        },
      ),
    );
  }

  void _onPaymentFailed() {
    if (_paymentDone) return;
    _paymentDone = true;
    _pollingTimer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Gagal'),
          ],
        ),
        content: const Text(
          'Transaksi dibatalkan atau kadaluarsa. Silakan coba lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // kembali ke detail order
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _showExitConfirmation,
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color      : Colors.black,
            fontWeight : FontWeight.bold,
            fontSize   : 16,
          ),
        ),
        centerTitle: true,
        actions: const [
          // Ikon gembok → sinyal aman ke user
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.lock, color: Color(0xFF4CAF50), size: 20),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFA726)),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // KONFIRMASI KELUAR
  // ─────────────────────────────────────────────────────────────
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Pembayaran belum selesai. Apakah kamu yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjut Bayar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // keluar dari webview
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DIALOG SUKSES PAYMENT
// ─────────────────────────────────────────────────────────────
class _PaymentSuccessDialog extends StatelessWidget {
  final double amount;
  final VoidCallback onClose;

  const _PaymentSuccessDialog({
    required this.amount,
    required this.onClose,
  });

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ikon centang ──
            Container(
              width  : 80,
              height : 80,
              decoration: const BoxDecoration(
                color : Color(0xFFE8F5E9),
                shape : BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color : Color(0xFF4CAF50),
                size  : 48,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              'Rp ${_formatPrice(amount)}',
              style: const TextStyle(
                fontSize   : 24,
                fontWeight : FontWeight.bold,
                color      : Color(0xFFFFA726),
              ),
            ),
            const SizedBox(height: 16),

            // ── Info box ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color        : Colors.grey.shade50,
                borderRadius : BorderRadius.circular(12),
                border       : Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.receipt_long,
                          size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bukti pembayaran dikirim ke email kamu',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notifications,
                          size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Freelancer akan segera diberitahu & mulai mengerjakan',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Tombol ──
            SizedBox(
              width  : double.infinity,
              height : 50,
              child  : ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Lihat Order Saya',
                  style: TextStyle(
                    color      : Colors.white,
                    fontWeight : FontWeight.bold,
                    fontSize   : 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}