import 'package:flutter/material.dart';
import '/controllers/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final int orderId;
  final String token;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.token,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? payment;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPayment();
  }

  void fetchPayment() async {
    try {
      final data = await PaymentService.getPayment(
        widget.orderId,
        widget.token,
      );

      setState(() {
        payment = data;
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  void openPayment(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (payment == null) {
      return const Scaffold(
        body: Center(child: Text("Payment not found")),
      );
    }

    double total = payment!['amount'];
    double base = total - 2000;
    double adminFee = 2000;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Payment Checkout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Complete payment to start project",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // DETAIL HARGA
              _row("Project Price", base),
              _row("Admin Fee", adminFee),

              const Divider(),

              _row("Total", total, bold: true),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Funds will be held in escrow until project is completed",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  openPayment(payment!['payment_url']);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Pay Now (Midtrans)"),
              ),

              const SizedBox(height: 10),

              const Text(
                "Secure payment via Midtrans",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rp ${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}