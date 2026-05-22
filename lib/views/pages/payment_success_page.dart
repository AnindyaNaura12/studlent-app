import 'package:flutter/material.dart';
import 'home_pages.dart';
import 'my_orders_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  final int idOrder;
  final String amount;
  final String serviceName;
  final String date;
  final String transactionType;
  final String selectedPackage;
  final String adminFee;

  const PaymentSuccessPage({
    super.key,
    required this.idOrder,
    required this.amount,
    required this.serviceName,
    this.date = '',
    this.transactionType = 'E - Wallet OVO',
    this.selectedPackage = '',
    this.adminFee = '0',
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFFA726);
    const Color darkColor = Color(0xFF1A1A2E);
    const Color greyColor = Color(0xFF9098B1);
    const Color bgColor = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // ── Success Icon ──
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Inner circle
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
                                weight: 700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Title ──
                      const Text(
                        "Payment Successful",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: darkColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── Subtitle ──
                      Text(
                        "Successful Paid Rp$amount",
                        style: const TextStyle(
                          fontSize: 14,
                          color: greyColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Receipt Card ──
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
                            // Section title
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                              child: Text(
                                "Payment methods",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: darkColor,
                                ),
                              ),
                            ),

                            // Thin divider
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

                            // Detail rows
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              child: Column(
                                children: [
                                  _buildRow("Transaction ID", "#$idOrder"),
                                  _buildRow("Date", date.isNotEmpty ? date : _formattedToday()),
                                  _buildRow("Type of Transaction", transactionType),
                                  _buildRow("Selected package", "Rp$selectedPackage"),
                                  _buildRow("Admin", "Rp$adminFee"),
                                  _buildRow(
                                    "Status",
                                    "Success",
                                    valueColor: const Color(0xFFFFA726),
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

            // ── Bottom Button (sticky) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
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
                  "Back Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: greyColor,
              fontWeight: FontWeight.w400,
            ),
          ),
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
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }
}