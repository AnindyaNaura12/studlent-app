import 'package:flutter/material.dart';
import '../../controllers/my_orders_controller.dart';
import '../../models/order_model.dart';
import 'order_detail_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final _controller = MyOrdersController();
  late Future<List<OrderModel>> _ordersFuture;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _controller.fetchUserOrders();
    });
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> all) {
    if (_selectedFilter == 'All') return all;

    return all.where((order) {
      final uiStatus = _uiStatus(order.status);

      if (_selectedFilter == 'Active') {
        return uiStatus == 'Pending' || uiStatus == 'In Progress';
      }

      if (_selectedFilter == 'Done') {
        return uiStatus == 'Done';
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

  Color _uiStatusBg(String rawStatus) {
    final status = _uiStatus(rawStatus);

    switch (status) {
      case 'Done':
        return Colors.green.withOpacity(0.15);
      case 'In Progress':
        return Colors.blue.withOpacity(0.15);
      case 'Pending':
        return Colors.orange.withOpacity(0.15);
      case 'Cancelled':
        return Colors.red.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _uiStatusText(String rawStatus) {
    final status = _uiStatus(rawStatus);

    switch (status) {
      case 'Done':
        return Colors.green[700]!;
      case 'In Progress':
        return Colors.blue[700]!;
      case 'Pending':
        return Colors.orange[800]!;
      case 'Cancelled':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  String _formatRawStatusDetail(String status) {
    switch (status.trim().toLowerCase()) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'diproses':
        return 'Diproses';
      case 'hasil_dikirim':
        return 'Hasil Dikirim';
      case 'revisi':
        return 'Revisi';
      case 'selesai':
        return 'Selesai';
      case 'pembayaran_gagal':
        return 'Pembayaran Gagal';
      case 'failed':
        return 'Failed';
      case 'expired':
        return 'Expired';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
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
                "My Orders",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: s(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(6)),
              child: Row(
                children: [
                  _filterBtn("All", s),
                  SizedBox(width: s(8)),
                  _filterBtn("Active", s),
                  SizedBox(width: s(8)),
                  _filterBtn("Done", s),
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
                    );
                  }

                  final all = snapshot.data ?? [];
                  final filtered = _getFilteredOrders(all);

                  if (filtered.isEmpty) {
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(s(16), s(4), s(16), s(16)),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _orderCard(filtered[index], s),
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

  Widget _filterBtn(String text, double Function(double) s) {
    final isActive = _selectedFilter == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = text;
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

  Widget _orderCard(OrderModel order, double Function(double) s) {
    final avatar = order.freelancerAvatar;
    final isNetworkImage = avatar.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
        );
      },
      child: Container(
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
                CircleAvatar(
                  radius: s(28),
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: avatar.isNotEmpty
                      ? (isNetworkImage
                            ? NetworkImage(avatar) as ImageProvider
                            : AssetImage(avatar))
                      : null,
                  child: avatar.isEmpty
                      ? Icon(Icons.person, color: Colors.grey, size: s(24))
                      : null,
                ),
                SizedBox(width: s(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: s(13),
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: s(2)),
                      Text(
                        order.freelancerName,
                        style: TextStyle(color: Colors.grey, fontSize: s(11)),
                      ),
                      SizedBox(height: s(6)),
                      Text(
                        order.price,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: s(10),
                    vertical: s(6),
                  ),
                  decoration: BoxDecoration(
                    color: _uiStatusBg(order.status),
                    borderRadius: BorderRadius.circular(s(20)),
                  ),
                  child: Text(
                    _uiStatus(order.status),
                    style: TextStyle(
                      fontSize: s(10),
                      fontWeight: FontWeight.bold,
                      color: _uiStatusText(order.status),
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
                      'Order ID',
                      style: TextStyle(fontSize: s(9), color: Colors.grey),
                    ),
                    Text(
                      '#${order.id}',
                      style: TextStyle(fontSize: s(11), color: Colors.black87),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deadline',
                      style: TextStyle(fontSize: s(9), color: Colors.grey),
                    ),
                    Text(
                      order.deadline,
                      style: TextStyle(fontSize: s(11), color: Colors.black87),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status Detail',
                      style: TextStyle(fontSize: s(9), color: Colors.grey),
                    ),
                    Text(
                      _formatRawStatusDetail(order.status),
                      style: TextStyle(
                        fontSize: s(10.5),
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
