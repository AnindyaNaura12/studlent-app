import 'package:flutter/material.dart';
import '../../controllers/my_orders_controller.dart';
import '../../models/order_model.dart';
import 'booking_detail_page.dart';
import 'login_page.dart';
import 'register_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final controller = MyOrdersController();
  late Future<List<OrderModel>> _ordersFuture;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _ordersFuture = controller.fetchUserOrders();
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = controller.fetchUserOrders();
    });
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    if (selectedFilter == 'All') return orders;

    return orders.where((o) {
      final status = _uiStatus(o.status);

      if (selectedFilter == 'Active') {
        return status == 'Pending' ||
            status == 'Diproses' ||
            status == 'Hasil Dikirim' ||
            status == 'Revisi';
      }

      if (selectedFilter == 'Done') {
        return status == 'Done';
      }

      return true;
    }).toList();
  }

  String _uiStatus(String rawStatus) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'pending':
      case 'menunggu_pembayaran':
      case 'menunggu_verifikasi':
        return 'Pending';

      case 'diproses':
      case 'paid':
      case 'in_progress':
        return 'Diproses';

      case 'hasil_dikirim':
        return 'Hasil Dikirim';

      case 'revisi':
        return 'Revisi';

      case 'done':
      case 'selesai':
        return 'Done';

      case 'dibatalkan':
      case 'pembayaran_gagal':
      case 'failed':
      case 'expired':
        return 'Cancelled';

      default:
        return 'Pending';
    }
  }

  String _formatOrderDate(DateTime? value) {
    if (value == null) return '-';

    final dt = value.toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();

    return '$day/$month/$year';
  }

  Widget _buildOrderImage(OrderModel b, double Function(double) s) {
    final image = b.serviceImage;

    if (image.isEmpty) {
      return Container(
        width: s(60),
        height: s(60),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(s(10)),
        ),
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: s(24)),
      );
    }

    if (image.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(s(10)),
        child: Image.network(
          image,
          width: s(60),
          height: s(60),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: s(60),
            height: s(60),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(s(10)),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: s(24),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(s(10)),
      child: Image.asset(
        image,
        width: s(60),
        height: s(60),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: s(60),
          height: s(60),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(s(10)),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: s(24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    // ── FutureBuilder dipindah ke level body Scaffold ──────────
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // ── 1. Cek error belum login SEBELUM render apapun ──
          if (snapshot.hasError) {
            final isUnauthorized = snapshot.error
                .toString()
                .toLowerCase()
                .contains('belum login');

            if (isUnauthorized) {
              // Fullscreen placeholder — filter TIDAK ditampilkan
              return _buildLoginPlaceholder(context);
            }

            // Error selain login → tampilan default dengan tombol Coba Lagi
            // Filter tetap ditampilkan karena user kemungkinan sudah login
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(s(20), s(16), s(20), s(4)),
                    child: Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: s(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(s(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ── 2. Kondisi normal (loading / sukses) ──────────────
          // Header + Filter + List — semua ditampilkan di sini
          return SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: EdgeInsets.fromLTRB(s(20), s(16), s(20), s(4)),
                  child: Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: s(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ── Filter tabs ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(16),
                    vertical: s(6),
                  ),
                  child: Row(
                    children: [
                      _filter("All", s),
                      SizedBox(width: s(8)),
                      _filter("Active", s),
                      SizedBox(width: s(8)),
                      _filter("Done", s),
                    ],
                  ),
                ),

                SizedBox(height: s(6)),

                // ── List area ──
                Expanded(
                  child: () {
                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFA726),
                        ),
                      );
                    }

                    final allOrders = snapshot.data ?? [];
                    final bookings = _filteredOrders(allOrders);

                    // Empty state
                    if (bookings.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        color: const Color(0xFFFFA726),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: s(100)),
                            Icon(
                              Icons.inbox,
                              size: s(64),
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada order.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    // Data state
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: const Color(0xFFFFA726),
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(s(16), s(4), s(16), s(16)),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          return _bookingCard(bookings[index], s);
                        },
                      ),
                    );
                  }(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Login Placeholder (fullscreen, tanpa filter) ───────────
  Widget _buildLoginPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD59E), Colors.white],
          stops: [0.0, 0.55],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Track Your Orders!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Login or sign up to view\nyour order history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8D8C0), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "You're not logged in yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login to start booking\nservices from freelancers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LoginPage(isFromMyOrders: true),
                            ),
                          ).then((_) => _refresh());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegisterPage(isFromMyOrders: true),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filter(String text, double Function(double) s) {
    final isActive = selectedFilter == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = text;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: s(9)),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFA726) : Colors.white,
            borderRadius: BorderRadius.circular(s(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: s(5),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(OrderModel b, double Function(double) s) {
    return Container(
      margin: EdgeInsets.only(bottom: s(12)),
      padding: EdgeInsets.all(s(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: s(8),
            offset: Offset(0, s(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderImage(b, s),
              SizedBox(width: s(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(13),
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      b.freelancerName,
                      style: TextStyle(color: Colors.grey, fontSize: s(11)),
                    ),
                    SizedBox(height: s(4)),
                    Text(
                      b.price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(12),
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: s(6)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(5)),
                decoration: BoxDecoration(
                  color: _statusColor(_uiStatus(b.status)),
                  borderRadius: BorderRadius.circular(s(18)),
                ),
                child: Text(
                  _uiStatus(b.status),
                  style: TextStyle(
                    fontSize: s(10),
                    fontWeight: FontWeight.bold,
                    color: _statusTextColor(_uiStatus(b.status)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Date",
                    style: TextStyle(fontSize: s(9), color: Colors.grey),
                  ),
                  Text(
                    _formatOrderDate(b.createdAt),
                    style: TextStyle(fontSize: s(11), color: Colors.black87),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deadline",
                    style: TextStyle(fontSize: s(9), color: Colors.grey),
                  ),
                  Text(
                    b.deadline,
                    style: TextStyle(fontSize: s(11), color: Colors.black87),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailPage(booking: b),
                    ),
                  );

                  if (result == true) {
                    await _refresh();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(12),
                    vertical: s(7),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(s(18)),
                  ),
                  child: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: s(11),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green.withOpacity(0.15);
      case "Diproses":
        return Colors.blue.withOpacity(0.15);
      case "Hasil Dikirim":
        return Colors.purple.withOpacity(0.15);
      case "Revisi":
        return Colors.deepOrange.withOpacity(0.15);
      case "Pending":
        return Colors.orange.withOpacity(0.15);
      case "Cancelled":
        return Colors.red.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green[700]!;
      case "Diproses":
        return Colors.blue[700]!;
      case "Hasil Dikirim":
        return Colors.purple[700]!;
      case "Revisi":
        return Colors.deepOrange[700]!;
      case "Pending":
        return Colors.orange[800]!;
      case "Cancelled":
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
