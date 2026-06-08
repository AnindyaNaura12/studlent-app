import 'package:flutter/material.dart';
import '../../controllers/my_orders_controller.dart';
import '../../models/order_model.dart';
import 'booking_detail_page.dart';

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
        return status == 'Pending' || status == 'In Progress';
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
      case 'hasil_dikirim':
      case 'revisi':
      case 'paid':
        return 'In Progress';
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(s(20), s(16), s(20), s(4)),
              child: Text(
                'My Orders',
                style: TextStyle(fontSize: s(20), fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(6)),
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
            Expanded(
              child: FutureBuilder<List<OrderModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFA726),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
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
                    );
                  }

                  final allOrders = snapshot.data ?? [];
                  final bookings = _filteredOrders(allOrders);

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
                },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailPage(booking: b),
                    ),
                  );
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
      case "In Progress":
        return Colors.blue.withOpacity(0.15);
      case "Pending":
        return Colors.orange.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green[700]!;
      case "In Progress":
        return Colors.blue[700]!;
      case "Pending":
        return Colors.orange[800]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
