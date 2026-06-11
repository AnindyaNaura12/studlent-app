import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/my_orders_controller.dart';
import '../../models/order_model.dart';

class _AttachmentItem {
  final File file;
  final String name;
  final bool isImage;

  const _AttachmentItem({
    required this.file,
    required this.name,
    required this.isImage,
  });
}

class RequestRevisionPage extends StatefulWidget {
  final OrderModel booking;

  const RequestRevisionPage({super.key, required this.booking});

  @override
  State<RequestRevisionPage> createState() => _RequestRevisionPageState();
}

class _RequestRevisionPageState extends State<RequestRevisionPage> {
  final TextEditingController _revisionController = TextEditingController();
  final List<_AttachmentItem> _attachments = [];
  bool _isLoading = false;
  final _ordersController = MyOrdersController();

  static const int _maxAttachments = 3;

  double _s(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375).clamp(0.85, 1.25);
    return size * scale;
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

  Future<void> _openCompletedFile() async {
    final String? rawUrl = widget.booking.fileUrl;

    if (rawUrl == null || rawUrl.isEmpty) {
      _showSnackBar("File hasil kerja belum tersedia.");
      return;
    }

    final Uri uri = Uri.parse(rawUrl);
    try {
      final bool canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar("Tidak dapat membuka file. Periksa koneksi Anda.");
      }
    } catch (_) {
      _showSnackBar("Terjadi kesalahan saat membuka file.");
    }
  }

  Future<void> _handleImagePick() async {
    if (_isLoading) return;

    if (_attachments.length >= _maxAttachments) {
      _showSnackBar("Maksimal $_maxAttachments lampiran.");
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();

      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (!mounted) return;
      if (pickedFiles.isEmpty) return;

      final int remaining = _maxAttachments - _attachments.length;
      final List<XFile> toAdd = pickedFiles.take(remaining).toList();

      if (toAdd.isEmpty) {
        _showSnackBar("Maksimal $_maxAttachments lampiran.");
        return;
      }

      setState(() {
        for (final xfile in toAdd) {
          if (xfile.path.trim().isEmpty) continue;
          _attachments.add(
            _AttachmentItem(
              file: File(xfile.path),
              name: xfile.name,
              isImage: true,
            ),
          );
        }
      });

      if (pickedFiles.length > remaining) {
        _showSnackBar(
          "Hanya $remaining gambar yang ditambahkan (batas $_maxAttachments).",
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal memilih gambar: ${e.toString()}");
    }
  }

  Future<void> _handleAttachment() async {
    if (_isLoading) return;

    if (_attachments.length >= _maxAttachments) {
      _showSnackBar("Maksimal $_maxAttachments lampiran.");
      return;
    }

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip'],
      );

      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;

      final int remaining = _maxAttachments - _attachments.length;
      final List<PlatformFile> toAdd = result.files.take(remaining).toList();

      final List<_AttachmentItem> newItems = [];
      for (final PlatformFile pf in toAdd) {
        final String? path = pf.path;
        if (path == null || path.isEmpty) continue;
        newItems.add(
          _AttachmentItem(file: File(path), name: pf.name, isImage: false),
        );
      }

      if (newItems.isNotEmpty) {
        setState(() => _attachments.addAll(newItems));
      }

      if (result.files.length > remaining) {
        _showSnackBar(
          "Hanya $remaining file yang ditambahkan (batas $_maxAttachments).",
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal memilih file: ${e.toString()}");
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<void> _submitRevision() async {
    final String revisionText = _revisionController.text.trim();

    if (revisionText.isEmpty) {
      _showSnackBar("Mohon deskripsikan permintaan revisi Anda.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderId = int.tryParse(widget.booking.id) ?? 0;

      if (orderId <= 0) {
        throw Exception('ID order tidak valid.');
      }

      final List<File> files = _attachments.map((a) => a.file).toList();
      final List<String> names = _attachments.map((a) => a.name).toList();

      final int newCount = await _ordersController.submitRequestRevision(
        orderId: orderId,
        revisionNote: revisionText,
        attachmentFiles: files,
        attachmentNames: names,
      );

      if (!mounted) return;
      _showSnackBar('Revisi ke-$newCount berhasil diajukan.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        "Gagal mengirim revisi: ${e.toString()}",
        bgColor: Colors.red[600],
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFreelancerAvatar() {
    final avatar = widget.booking.freelancerAvatar;

    if (avatar.isEmpty) {
      return Container(
        width: _s(56),
        height: _s(56),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE0B2),
          borderRadius: BorderRadius.circular(_s(12)),
        ),
        child: Icon(
          Icons.person_rounded,
          color: const Color(0xFFFFA726),
          size: _s(28),
        ),
      );
    }

    if (avatar.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_s(12)),
        child: Image.network(
          avatar,
          width: _s(56),
          height: _s(56),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: _s(56),
            height: _s(56),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0B2),
              borderRadius: BorderRadius.circular(_s(12)),
            ),
            child: Icon(
              Icons.person_rounded,
              color: const Color(0xFFFFA726),
              size: _s(28),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(_s(12)),
      child: Image.asset(
        avatar,
        width: _s(56),
        height: _s(56),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: _s(56),
          height: _s(56),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(_s(12)),
          ),
          child: Icon(
            Icons.person_rounded,
            color: const Color(0xFFFFA726),
            size: _s(28),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _revisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMaxAttachments = _attachments.length >= _maxAttachments;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(_s(20), _s(8), _s(20), _s(16)),
          child: SizedBox(
            width: double.infinity,
            height: _s(52),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRevision,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                disabledBackgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_s(30)),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: _s(22),
                      height: _s(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black54,
                        ),
                      ),
                    )
                  : Text(
                      "Submit your Revision",
                      style: TextStyle(
                        fontSize: _s(14),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: _s(60),
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF8EE), Color(0xFFFFFDF9)],
                ),
              ),
            ),
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: _s(22),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Request Revisions",
                      style: TextStyle(
                        fontSize: _s(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: _s(22)),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(_s(16), _s(8), _s(16), _s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFreelancerCard(),
                  SizedBox(height: _s(20)),
                  _buildViewOrderSection(),
                  SizedBox(height: _s(20)),
                  _buildRevisionInputSection(isMaxAttachments),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreelancerCard() {
    return Container(
      padding: EdgeInsets.all(_s(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_s(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: _s(12),
            offset: Offset(0, _s(4)),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFreelancerAvatar(),
          SizedBox(width: _s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.freelancerName,
                  style: TextStyle(
                    fontSize: _s(14),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _s(3)),
                Text(
                  widget.booking.serviceName,
                  style: TextStyle(fontSize: _s(12), color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "View Order",
          style: TextStyle(
            fontSize: _s(14),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: _s(10)),
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
                vertical: _s(20),
                horizontal: _s(16),
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
                    size: _s(22),
                  ),
                  SizedBox(width: _s(8)),
                  Text(
                    "View File",
                    style: TextStyle(
                      fontSize: _s(13),
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
    );
  }

  Widget _buildRevisionInputSection(bool isMaxAttachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Request Revisions",
          style: TextStyle(
            fontSize: _s(14),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: _s(10)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_s(16)),
            border: Border.all(
              color: Colors.grey.withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: _s(8),
                offset: Offset(0, _s(2)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(_s(14), _s(12), _s(14), _s(4)),
                child: TextField(
                  controller: _revisionController,
                  maxLines: 6,
                  style: TextStyle(fontSize: _s(13), color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Type here...",
                    hintStyle: TextStyle(
                      fontSize: _s(13),
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_attachments.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(_s(12), 0, _s(12), _s(8)),
                  child: Wrap(
                    spacing: _s(8),
                    runSpacing: _s(8),
                    children: List.generate(
                      _attachments.length,
                      (index) => _buildAttachmentPreview(index),
                    ),
                  ),
                ),
              ],
              Padding(
                padding: EdgeInsets.fromLTRB(_s(10), _s(4), _s(10), _s(10)),
                child: Row(
                  children: [
                    _toolbarIconButton(
                      icon: Icons.attach_file_rounded,
                      onTap: isMaxAttachments
                          ? () => _showSnackBar(
                              "Maksimal $_maxAttachments lampiran.",
                            )
                          : _handleAttachment,
                      tooltip: "Lampirkan file",
                      disabled: isMaxAttachments,
                    ),
                    SizedBox(width: _s(4)),
                    _toolbarIconButton(
                      icon: Icons.image_outlined,
                      onTap: isMaxAttachments
                          ? () => _showSnackBar(
                              "Maksimal $_maxAttachments lampiran.",
                            )
                          : _handleImagePick,
                      tooltip: "Tambah gambar",
                      disabled: isMaxAttachments,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentPreview(int index) {
    final _AttachmentItem item = _attachments[index];

    return SizedBox(
      width: _s(76),
      height: _s(76),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: item.isImage
                    ? Colors.transparent
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(_s(10)),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: item.isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(_s(10)),
                      child: Image.file(
                        item.file,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fileIconPlaceholder(),
                      ),
                    )
                  : _fileChipContent(item.name),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _removeAttachment(index),
              child: Container(
                width: _s(18),
                height: _s(18),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: _s(11), color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileIconPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(_s(10)),
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: _s(28),
        color: Colors.grey[400],
      ),
    );
  }

  Widget _fileChipContent(String name) {
    return Padding(
      padding: EdgeInsets.all(_s(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_rounded,
            color: const Color(0xFF6B7AFF),
            size: _s(24),
          ),
          SizedBox(height: _s(3)),
          Text(
            name,
            style: TextStyle(fontSize: _s(9), color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _toolbarIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool disabled = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(_s(6)),
          decoration: BoxDecoration(
            color: disabled
                ? Colors.grey.withOpacity(0.04)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(_s(8)),
          ),
          child: Icon(
            icon,
            size: _s(18),
            color: disabled ? Colors.grey[350] : const Color(0xFF2D2D2D),
          ),
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
