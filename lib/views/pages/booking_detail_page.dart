import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/order_model.dart';
import 'contact_freelancer_page.dart';
import 'request_revision_page.dart';
import 'rating_review_page.dart';
import '../../controllers/my_orders_controller.dart';

class BookingDetailPage extends StatefulWidget {
  final OrderModel booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late OrderModel booking;

  final _ordersController = MyOrdersController();
  bool _isRequestingRevision = false;
  int _revisionCount = 0; 
  String? _revisionNote;
  String? _revisionFileUrl;

  @override
  void initState() {
    super.initState();
    booking = widget.booking;
    _refreshBooking();
  }

  Future<void> _handleRequestRevision() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => RequestRevisionPage(booking: booking),
    ),
  );

  if (result == true) {
    await _refreshBooking();
  }
}

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

  Future<void> _refreshBooking() async {
  try {
    final supabase = Supabase.instance.client;
    final orderId = int.tryParse(booking.id) ?? 0;

    final Map<String, dynamic>? res = await supabase
        .from('orders')
        .select('''
          id_order,
          id_freelancer,
          id_service,
          status,
          catatan,
          deadline,
          result_file_url,
          revision_count,
          revision_note,
          revision_file_url,
          created_at,
          freelancer:id_freelancer (nama, foto),
          service:id_service (judul, thumbnail_url, service_images(image_url)),
          payment:payments (amount, admin_fee, status, metode)
        ''')
        .eq('id_order', orderId)
        .maybeSingle();

    if (res == null) {
      if (mounted) {
        _showSnackBar("Data order tidak ditemukan.");
      }
      return;
    }

    if (res['result_file_url'] == null ||
        res['result_file_url'].toString().trim().isEmpty) {
      final Map<String, dynamic>? latestDeliverable = await supabase
          .from('deliverables')
          .select('file_url, created_at')
          .eq('id_order', orderId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (latestDeliverable != null &&
          latestDeliverable['file_url'] != null &&
          latestDeliverable['file_url'].toString().trim().isNotEmpty) {
        res['result_file_url'] = latestDeliverable['file_url'];
      }
    }

    if (!mounted) return;

    setState(() {
      booking = OrderModel.fromJson(res);
      _revisionCount = (res['revision_count'] as num?)?.toInt() ?? 0;
      _revisionNote = res['revision_note']?.toString().trim();
      _revisionFileUrl = res['revision_file_url']?.toString().trim();
    });
  } catch (e) {
    if (mounted) {
      _showSnackBar("Gagal memuat data terbaru.");
    }
  }
}

  Future<void> _openCompletedFile() async {
    final String? rawUrl = booking.fileUrl;

    if (rawUrl == null || rawUrl.trim().isEmpty) {
      _showSnackBar("File hasil kerja belum tersedia.");
      return;
    }

    try {
      final Uri uri = Uri.parse(rawUrl.trim());

      if (await canLaunchUrl(uri)) {
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

  String _uiPaymentStatus(String rawStatus) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'pending':
        return 'Pembayaran Selesai';
      case 'paid':
      case 'success':
      case 'settlement':
        return 'Pembayaran Selesai';
      case 'failed':
      case 'cancel':
      case 'cancelled':
      case 'expired':
        return 'Pembayaran Gagal';
      default:
        return rawStatus.isEmpty ? '-' : rawStatus;
    }
  }

  bool _canViewOrderFile(String rawStatus) {
    final s = rawStatus.trim().toLowerCase();
    return s == 'hasil_dikirim' || s == 'done' || s == 'selesai';
  }

  bool _canClientReview(String rawStatus) {
    final s = rawStatus.trim().toLowerCase();
    return s == 'hasil_dikirim' || s == 'done' || s == 'selesai';
  }

  bool _canRequestRevision(String rawStatus) {
    return rawStatus.trim().toLowerCase() == 'hasil_dikirim' &&
        _revisionCount < 3;
  }

  Widget _buildServiceImage(double size) {
    final image = booking.serviceImage;

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
                          booking.serviceName,
                          style: TextStyle(
                            fontSize: s(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: s(4)),
                        Text(
                          booking.freelancerName,
                          style: TextStyle(fontSize: s(12), color: Colors.grey),
                        ),
                        SizedBox(height: s(6)),
                        Text(
                          booking.price,
                          style: TextStyle(
                            fontSize: s(13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(booking.status, s),
                ],
              ),
            ),
            SizedBox(height: s(18)),

            if (_canViewOrderFile(booking.status)) ...[
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
                  _item("Order ID", '#${booking.id}', s),
                  _divider(s),
                  _item("Deadline", booking.deadline, s),
                  _divider(s),
                  _item("Status", _uiStatus(booking.status), s),
                  _divider(s),
                  _item("Payment Method", booking.paymentMethod, s),
                  _divider(s),
                  _item(
                    "Payment Status",
                    _uiPaymentStatus(booking.paymentStatus),
                    s,
                  ),
                ],
              ),
            ),

            if (_revisionCount > 0 || booking.status == 'revisi') ...[
              SizedBox(height: s(14)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: s(14),
                  vertical: s(10),
                ),
                decoration: BoxDecoration(
                  color: _revisionCount >= 3
                      ? Colors.red.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(s(12)),
                  border: Border.all(
                    color: _revisionCount >= 3
                        ? Colors.red.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: s(16),
                      color: _revisionCount >= 3
                          ? Colors.red.shade600
                          : Colors.orange.shade700,
                    ),
                    SizedBox(width: s(8)),
                    Text(
                      'Revisi ke-$_revisionCount dari 3',
                      style: TextStyle(
                        fontSize: s(12),
                        fontWeight: FontWeight.w600,
                        color: _revisionCount >= 3
                            ? Colors.red.shade700
                            : Colors.orange.shade800,
                      ),
                    ),
                    if (_revisionCount >= 3) ...[
                      const Spacer(),
                      Text(
                        'Batas tercapai',
                        style: TextStyle(
                          fontSize: s(11),
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // --- Catatan Revisi ---
              SizedBox(height: s(10)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(s(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(s(12)),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Revisi Anda:',
                      style: TextStyle(
                        fontSize: s(12),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: s(6)),
                    if (_revisionNote != null && _revisionNote!.trim().isNotEmpty)
                      Text(
                        _revisionNote!,
                        style: TextStyle(
                          fontSize: s(12),
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      )
                    else
                      Text(
                        'Tidak ada catatan revisi.',
                        style: TextStyle(
                          fontSize: s(12),
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              // --- File Lampiran Revisi ---
              SizedBox(height: s(8)),
              if (_revisionFileUrl != null && _revisionFileUrl!.trim().isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.tryParse(_revisionFileUrl!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      _showSnackBar('Tidak dapat membuka lampiran.');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: s(14),
                      vertical: s(12),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.circular(s(12)),
                      border: Border.all(color: const Color(0xFFADB5FF)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          color: const Color(0xFF6B7AFF),
                          size: s(20),
                        ),
                        SizedBox(width: s(10)),
                        Expanded(
                          child: Text(
                            'Lihat Lampiran Revisi',
                            style: TextStyle(
                              fontSize: s(13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7AFF),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.open_in_new_rounded,
                          color: const Color(0xFF6B7AFF),
                          size: s(16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.only(left: s(4)),
                  child: Text(
                    'Tidak ada lampiran file revisi.',
                    style: TextStyle(
                      fontSize: s(12),
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],

            SizedBox(height: s(24)),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactFreelancerPage(
                        freelancerId: booking.freelancerId,
                        freelancerName: booking.freelancerName,
                        image: booking.freelancerAvatar,
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

            if (_canRequestRevision(booking.status)) ...[
              SizedBox(height: s(12)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isRequestingRevision ? null : _handleRequestRevision,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFA726),
                    side: const BorderSide(color: Color(0xFFFFA726), width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: s(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(s(25)),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: _isRequestingRevision
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFA726),
                          ),
                        )
                      : Text(
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

            if (_canClientReview(booking.status)) ...[
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
                            onPressed: () async {
                              Navigator.pop(ctx);

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RatingReviewPage(
                                    idOrder: int.tryParse(booking.id) ?? 0,
                                    idClient: 0,
                                    idFreelancer: booking.freelancerId,
                                    idService: booking.serviceId,
                                    freelancerName: booking.freelancerName,
                                    freelancerImage: booking.freelancerAvatar,
                                    serviceName: booking.serviceName,
                                  ),
                                ),
                              );

                              if (result == true) {
                                await _refreshBooking();
                              }
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
                    "Order Complete",
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
    final hasFile =
        booking.fileUrl != null && booking.fileUrl!.trim().isNotEmpty;

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
            onTap: hasFile ? _openCompletedFile : null,
            child: Opacity(
              opacity: hasFile ? 1 : 0.6,
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file_rounded,
                            color: const Color(0xFF6B7AFF),
                            size: s(22),
                          ),
                          SizedBox(width: s(8)),
                          Text(
                            hasFile
                                ? "Lihat File Hasil"
                                : "File belum tersedia",
                            style: TextStyle(
                              fontSize: s(13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7AFF),
                            ),
                          ),
                        ],
                      ),
                      if (hasFile) ...[
                        SizedBox(height: s(8)),
                        Text(
                          booking.fileUrl!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: s(10),
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
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
      case "Diproses":
        bg = Colors.blue.withOpacity(0.15);
        text = Colors.blue[700]!;
        break;
      case "Hasil Dikirim":
        bg = Colors.purple.withOpacity(0.15);
        text = Colors.purple[700]!;
        break;
      case "Revisi":
        bg = Colors.deepOrange.withOpacity(0.15);
        text = Colors.deepOrange[700]!;
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
  bool shouldRepaint(covariant _DashedBorderPainter old) {
    return old.color != color ||
        old.dashWidth != dashWidth ||
        old.dashSpace != dashSpace ||
        old.strokeWidth != strokeWidth ||
        old.borderRadius != borderRadius;
  }
}
