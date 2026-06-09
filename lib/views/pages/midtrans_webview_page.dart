import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_success_page.dart';
import 'payment_failed_page.dart';

class MidtransWebViewPage extends StatefulWidget {
  final String snapUrl;
  final int orderId;
  final double amount;

  const MidtransWebViewPage({
    super.key,
    required this.snapUrl,
    required this.orderId,
    required this.amount,
  });

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isHandled = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
            _handleUrl(url);
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (url.contains('studlent.app/payment/finish')) {
              _handleFinishUrl(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.snapUrl));
  }

  void _handleUrl(String url) {
    if (url.contains('studlent.app/payment/finish')) {
      _handleFinishUrl(url);
    }
  }

  void _handleFinishUrl(String url) {
    if (_isHandled) return;
    _isHandled = true;

    final uri = Uri.parse(url);
    final orderIdRaw = uri.queryParameters['order_id'] ?? '';
    final trxStatus = (uri.queryParameters['transaction_status'] ?? '')
        .toLowerCase();

    final parsedOrderId = _extractNumericOrderId(orderIdRaw);
    final finalOrderId = parsedOrderId > 0 ? parsedOrderId : widget.orderId;

    debugPrint('Finish URL: $url');
    debugPrint('orderIdRaw: $orderIdRaw');
    debugPrint('trxStatus: $trxStatus');
    debugPrint('parsed orderId: $parsedOrderId');
    debugPrint('final orderId: $finalOrderId');

    if (!mounted) return;

    if (trxStatus == 'settlement' ||
        trxStatus == 'capture' ||
        trxStatus == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentSuccessPage(idOrder: finalOrderId, amount: widget.amount),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFailedPage(orderId: finalOrderId),
      ),
    );
  }

  int _extractNumericOrderId(String raw) {
    final match = RegExp(r'(\d+)$').firstMatch(raw);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
        ],
      ),
    );
  }
}
