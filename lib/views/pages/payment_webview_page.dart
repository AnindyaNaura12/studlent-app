import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'payment_failed_page.dart';
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
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
            _checkFinishUrl(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (_isMidtransFinishUrl(url)) {
              _handlePaymentRedirect(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isMidtransFinishUrl(String url) {
    return url.contains('studlent.app/payment/finish');
  }

  void _checkFinishUrl(String url) {
    if (_isMidtransFinishUrl(url)) {
      _handlePaymentRedirect(url);
    }
  }

  void _handlePaymentRedirect(String url) {
    if (_isHandled) return;
    _isHandled = true;

    final uri = Uri.parse(url);

    final orderIdRaw = uri.queryParameters['order_id'] ?? '';
    final transactionStatus = (uri.queryParameters['transaction_status'] ?? '')
        .toLowerCase();
    final statusCode = uri.queryParameters['status_code'] ?? '';

    final parsedOrderId = _extractNumericOrderId(orderIdRaw);
    final finalOrderId = parsedOrderId > 0 ? parsedOrderId : widget.orderId;

    debugPrint('Payment redirect detected: $url');
    debugPrint('order_id: $orderIdRaw');
    debugPrint('transaction_status: $transactionStatus');
    debugPrint('status_code: $statusCode');

    if (!mounted) return;

    if (transactionStatus == 'settlement' ||
        transactionStatus == 'capture' ||
        transactionStatus == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentSuccessPage(idOrder: finalOrderId, amount: widget.amount),
        ),
      );
      return;
    }

    if (transactionStatus == 'pending') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentFailedPage(orderId: finalOrderId),
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

  Future<bool> _onWillPop() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFA726);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Pembayaran',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
