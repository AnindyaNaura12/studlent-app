import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_success_page.dart';

const String _baseUrl = 'http://10.0.2.2:8000/api';
// const String _baseUrl = 'http://192.168.0.109:8000/api'; // device fisik

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final int    orderId;
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
  late final WebViewController _wvc;
  final _supabase = Supabase.instance.client;
  bool _isLoading   = true;
  bool _paymentDone = false;
  Timer? _pollingTimer;

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

  void _initWebView() {
    _wvc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        // ← FIX: tambah mounted check
        onPageStarted: (_) { if (mounted) setState(() => _isLoading = true);  },
        onPageFinished: (_) { if (mounted) setState(() => _isLoading = false); },
        onNavigationRequest: (req) => _intercept(req.url),
        onWebResourceError: (e) => debugPrint('WebView error: ${e.description}'),
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  NavigationDecision _intercept(String url) {
    debugPrint('WebView → $url');

    // Intercept callback URL dari MidtransService
    if (url.contains('studlent.app/payment/finish')) { _onSuccess(); return NavigationDecision.prevent; }
    if (url.contains('studlent.app/payment/error'))  { _onFailed();  return NavigationDecision.prevent; }
    if (url.contains('studlent.app/payment/pending')) { _onPending(); return NavigationDecision.prevent; }

    // Fallback: cek query param transaction_status
    final uri    = Uri.tryParse(url);
    final status = uri?.queryParameters['transaction_status'];
    if (status == 'settlement' || status == 'capture') { _onSuccess(); return NavigationDecision.prevent; }
    if (status == 'pending')                           { _onPending(); return NavigationDecision.prevent; }
    if (status == 'cancel' || status == 'deny' || status == 'expire') { _onFailed(); return NavigationDecision.prevent; }

    return NavigationDecision.navigate;
  }

  // ── Polling backup tiap 4 detik ───────────────────────────
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_paymentDone || !mounted) return;
      await _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/orders/${widget.orderId}/status'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['is_paid'] == true)              _onSuccess();
        else if (data['payment_status'] == 'failed') _onFailed();
      }
    } catch (_) { /* retry di iterasi berikut */ }
  }

  // ── FIX: update Supabase sebelum navigate ─────────────────
  Future<void> _updateSupabase(String paymentStatus, String orderStatus) async {
    try {
      await _supabase.from('payments')
          .update({'status': paymentStatus})
          .eq('id_order', widget.orderId);

      await _supabase.from('orders')
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

    // ← FIX: update Supabase dulu, baru navigate ke PaymentSuccessPage
    _updateSupabase('paid', 'paid').then((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PaymentSuccessPage(
          idOrder: widget.orderId,
          amount:  widget.amount,
        )),
        (route) => route.isFirst,
      );
    });
  }

  void _onPending() {
    if (_paymentDone) return;
    _paymentDone = true;
    _pollingTimer?.cancel();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => PaymentSuccessPage(
        idOrder:   widget.orderId,
        amount:    widget.amount,
        isPending: true,
      )),
      (route) => route.isFirst,
    );
  }

  void _onFailed() {
    if (_paymentDone) return;
    _paymentDone = true;
    _pollingTimer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text('Pembayaran Gagal'),
        ]),
        content: const Text('Transaksi dibatalkan atau kadaluarsa. Silakan coba lagi.'),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA726)),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Pembayaran belum selesai. Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjut Bayar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // kembali ke detail order
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ← FIX: cegah hardware back langsung keluar tanpa konfirmasi
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _showExitConfirmation,
          ),
          title: const Text('Pembayaran',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.lock, color: Color(0xFF4CAF50), size: 20),
            ),
          ],
        ),
        body: Stack(children: [
          WebViewWidget(controller: _wvc),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFFA726))),
        ]),
      ),
    );
  }
}