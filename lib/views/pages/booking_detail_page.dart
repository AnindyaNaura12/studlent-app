import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order_model.dart';
import 'contact_freelancer_page.dart';
import 'request_revision_page.dart';
import 'rating_review_page.dart';

class BookingDetailPage extends StatefulWidget {
  final OrderModel booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  void _showSnackBar(String message, {Color? bgColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor ?? const Color(0xFFFFA726),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openCompletedFile() async {
    final String? rawUrl = widget.booking.fileUrl;

    if (rawUrl == null || rawUrl.trim().isEmpty) {
      _showSnackBar("File hasil kerja belum tersedia.");
      return;
    }

    try {
      final Uri uri = Uri.parse(rawUrl.trim());

      final bool canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar("Tidak dapat membuka file. Periksa koneksi Anda.");
      }
    } catch (_) {
      _showSnackBar("URL file tidak valid atau terjadi kesalahan.");
    }
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

  bool _isDoneStatus(String rawStatus) {
    final s = rawStatus.trim().toLowerCase();
    return s == 'selesai';
  }

  bool _canViewOrderFile(String rawStatus) {
    final s = rawStatus.trim().toLowerCase();
    return s == 'hasil_dikirim' || s == 'selesai';
  }

  Widget _buildServiceImage(double size) {
    final image = widget.booking.serviceImage;

    if (image.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.image, color: Colors.grey, size: size * 0.45),
      );
    }

    if (image.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          image,
          key: ValueKey(image),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image, color: Colors.grey, size: size * 0.45),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.image, color: Colors.grey, size: size * 0.45),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EE),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Order Detail",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(s(14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(s(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: s(10),
                    offset: Offset(0, s(4)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildServiceImage(s(70)),
                  SizedBox(width: s(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.serviceName,
                          style: TextStyle(
                            fontSize: s(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: s(4)),
                        Text(
                          widget.booking.freelancerName,
                          style: TextStyle(fontSize: s(12), color: Colors.grey),
                        ),
                        SizedBox(height: s(6)),
                        Text(
                          widget.booking.price,
                          style: TextStyle(
                            fontSize: s(13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(widget.booking.status, s),
                ],
              ),
            ),
            SizedBox(height: s(18)),
            if (_canViewOrderFile(widget.booking.status)) ...[
              _buildViewOrderSection(s),
              SizedBox(height: s(18)),
            ],
            Container(
              padding: EdgeInsets.all(s(14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(s(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: s(10),
                    offset: Offset(0, s(4)),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _item("Order ID", '#${widget.booking.id}', s),
                  _divider(s),
                  _item("Deadline", widget.booking.deadline, s),
                  _divider(s),
                  _item("Status", _uiStatus(widget.booking.status), s),
                  _divider(s),
                  _item("Payment Method", widget.booking.paymentMethod, s),
                  _divider(s),
                  _item("Payment Status", widget.booking.paymentStatus, s),
                ],
              ),
            ),
            SizedBox(height: s(24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactFreelancerPage(
                        freelancerId: widget.booking.freelancerId,
                        freelancerName: widget.booking.freelancerName,
                        image: widget.booking.freelancerAvatar,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: s(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(25)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Contact Freelancer",
                  style: TextStyle(
                    fontSize: s(13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_isDoneStatus(widget.booking.status)) ...[
              SizedBox(height: s(12)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RequestRevisionPage(booking: widget.booking),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFA726),
                    side: const BorderSide(
                      color: Color(0xFFFFA726),
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: s(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(s(25)),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    "Request Revisi",
                    style: TextStyle(
                      fontSize: s(13),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA726),
                    ),
                  ),
                ),
              ),
            ],
            if (_isDoneStatus(widget.booking.status)) ...[
              SizedBox(height: s(12)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(s(20)),
                        ),
                        title: const Text(
                          "Complete the order?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Make sure you have received and checked the work properly. If completed, the funds will be transferred to the freelancer.",
                          style: TextStyle(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA726),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RatingReviewPage(
                                    idOrder:
                                        int.tryParse(widget.booking.id) ?? 0,
                                    idClient: 0,
                                    idFreelancer: widget.booking.freelancerId,
                                    freelancerName:
                                        widget.booking.freelancerName,
                                    freelancerImage:
                                        widget.booking.freelancerAvatar,
                                    serviceName: widget.booking.serviceName,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Yes, Done",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE082),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: s(14)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(s(25)),
                    ),
                  ),
                  child: Text(
                    "Order complete",
                    style: TextStyle(
                      fontSize: s(13),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: s(16)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewOrderSection(double Function(double) s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: s(10),
            offset: Offset(0, s(4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "View Order",
            style: TextStyle(
              fontSize: s(14),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: s(10)),
          GestureDetector(
            onTap: _openCompletedFile,
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: const Color(0xFFADB5FF),
                borderRadius: 14,
                dashWidth: 6,
                dashSpace: 4,
                strokeWidth: 1.5,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: s(20),
                  horizontal: s(16),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      color: const Color(0xFF6B7AFF),
                      size: s(22),
                    ),
                    SizedBox(width: s(8)),
                    Text(
                      "View File",
                      style: TextStyle(
                        fontSize: s(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7AFF),
                      ),
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

  Widget _item(String title, String value, double Function(double) s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: s(12), color: Colors.grey),
          ),
          SizedBox(width: s(12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: s(12), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(double Function(double) s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(6)),
      child: Divider(thickness: 0.6, color: Colors.grey.withOpacity(0.3)),
    );
  }

  Widget _statusBadge(String status, double Function(double) s) {
    final uiStatus = _uiStatus(status);
    Color bg;
    Color text;

    switch (uiStatus) {
      case "Done":
        bg = Colors.green.withOpacity(0.15);
        text = Colors.green[700]!;
        break;
      case "In Progress":
        bg = Colors.blue.withOpacity(0.15);
        text = Colors.blue[700]!;
        break;
      case "Pending":
        bg = Colors.orange.withOpacity(0.15);
        text = Colors.orange[800]!;
        break;
      case "Cancelled":
        bg = Colors.red.withOpacity(0.15);
        text = Colors.red[700]!;
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(s(20)),
      ),
      child: Text(
        uiStatus,
        style: TextStyle(
          fontSize: s(10),
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final PathMetrics metrics = path.computeMetrics();

    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius;
}
