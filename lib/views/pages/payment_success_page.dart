// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_pages.dart';
import 'my_orders_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  // ← FIX: constructor diubah — hanya butuh idOrder & amount
  // sisanya di-fetch dari Supabase
  final int    idOrder;
  final double amount;    // ← FIX: was String, sekarang double
  final bool   isPending;

  const PaymentSuccessPage({
    super.key,
    required this.idOrder,
    required this.amount,
    this.isPending = false,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final _supabase = Supabase.instance.client;
  bool   _isLoading   = true;
  String _metode      = '-';
  String _serviceName = '-';
  String _date        = '';
  double _adminFee    = 2500;
  bool   _isPaid      = true;

  @override
  void initState() {
    super.initState();
    _isPaid = !widget.isPending;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Ambil data payment
      final payment = await _supabase
          .from('payments')
          .select('metode, amount, admin_fee, status, created_at')
          .eq('id_order', widget.idOrder)
          .maybeSingle();

      // Ambil nama service dari order
      final order = await _supabase
          .from('orders')
          .select('detail_pesanan, services!id_service(judul)')
          .eq('id_order', widget.idOrder)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _metode   = payment?['metode']?.toString() ?? '-';
          _adminFee = (payment?['admin_fee'] as num?)?.toDouble() ?? 2500;

          final createdAt = payment?['created_at']?.toString();
          _date = createdAt != null ? _formatDate(createdAt) : _formattedToday();

          final status = payment?['status']?.toString();
          _isPaid = status == 'paid';

          // Ambil judul service dari join
          final svc = order?['services'];
          _serviceName = (svc is Map)
              ? svc['judul']?.toString() ?? '-'
              : order?['detail_pesanan']?.toString() ?? '-';

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching payment data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFFA726);
    const Color darkColor    = Color(0xFF1A1A2E);
    const Color greyColor    = Color(0xFF9098B1);
    const Color bgColor      = Color(0xFFF5F5F5);

    final bool   isPending    = !_isPaid || widget.isPending;
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
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 48),

                            // ── Icon ──
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 110, height: 110,
                                    decoration: BoxDecoration(
                                      color: (isPending ? Colors.blue : primaryColor).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 82, height: 82,
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: isPending
                                            ? [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]
                                            : [const Color(0xFFFFD54F), const Color(0xFFFFA726)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPending ? Icons.hourglass_top_rounded : Icons.check,
                                      color: Colors.white, size: 38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Title ──
                            Text(
                              isPending ? 'Menunggu Pembayaran' : 'Payment Successful',
                              style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800,
                                color: darkColor, letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isPending
                                  ? 'Selesaikan pembayaran sesuai instruksi yang dikirim'
                                  : 'Berhasil membayar Rp${_fmt(widget.amount)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14, color: greyColor, fontWeight: FontWeight.w400,
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
                                  BoxShadow(color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                                    child: Text('Detail Pembayaran',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.w700, color: darkColor)),
                                  ),
                                  const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                                    child: Column(children: [
                                      _buildRow('Transaction ID', '#${widget.idOrder}'),
                                      _buildRow('Tanggal', _date.isNotEmpty ? _date : _formattedToday()),
                                      _buildRow('Metode Bayar', _metode),
                                      _buildRow('Jasa', _serviceName),
                                      _buildRow('Harga Paket', 'Rp${_fmt(packagePrice)}'),
                                      _buildRow('Biaya Admin', 'Rp${_fmt(_adminFee)}'),
                                      _buildRow('Total', 'Rp${_fmt(widget.amount)}', valueBold: true),
                                      _buildRow('Status',
                                          isPending ? 'Menunggu' : 'Sukses',
                                          valueColor: isPending ? Colors.orange : primaryColor,
                                          valueBold: true),
                                    ]),
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

                  // ── Tombol ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Column(children: [
                      ElevatedButton(
                        onPressed: () => _goHome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text('Back Home',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _goToOrders(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryColor),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Lihat Order Saya',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                color: primaryColor)),
                      ),
                    ]),
                  ),
                ]),
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

  Widget _buildRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    const Color greyColor = Color(0xFF9098B1);
    const Color darkColor = Color(0xFF1A1A2E);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: greyColor)),
        Flexible(
          child: Text(value, textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13,
                fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? darkColor)),
        ),
      ]),
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    const m = ['Januari','Februari','Maret','April','Mei','Juni',
        'Juli','Agustus','September','Oktober','November','Desember'];
    return '${now.day} ${m[now.month - 1]} ${now.year}';
  }

  String _formatDate(String s) {
    try {
      final d = DateTime.parse(s);
      const m = ['Januari','Februari','Maret','April','Mei','Juni',
          'Juli','Agustus','September','Oktober','November','Desember'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) { return s; }
  }

  String _fmt(double price) {
    final s = price.toInt().toString();
    final b = StringBuffer();
    int c   = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) b.write('.');
      b.write(s[i]); c++;
    }
    return b.toString().split('').reversed.join();
  }
}