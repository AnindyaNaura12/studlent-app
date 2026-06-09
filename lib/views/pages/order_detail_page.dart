// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config.dart';
import '../../models/order_model.dart';

// ── PERUBAHAN 1: class _RefFile diubah ──────────────────────
// Sebelumnya: hanya punya url + catatan (dari tabel deliverables)
// Sekarang:   punya fileUrl, fileName, imageUrl, imageName (dari tabel orders)
class _RefFile {
  final String? fileUrl;
  final String? fileName;
  final String? imageUrl;
  final String? imageName;

  _RefFile({this.fileUrl, this.fileName, this.imageUrl, this.imageName});
}

class FreelancerOrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const FreelancerOrderDetailPage({super.key, required this.order});

  @override
  State<FreelancerOrderDetailPage> createState() =>
      _FreelancerOrderDetailPageState();
}

class _FreelancerOrderDetailPageState extends State<FreelancerOrderDetailPage> {
  static const Color _bg = Color(0xFFFFF8EE);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _softPurple = Color(0xFFEEF1FF);
  static const Color _purple = Color(0xFF6B7AFF);

  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  List<_RefFile> _refFiles = [];
  bool _loadingRef = true;

  bool _isSubmitting = false;
  String? _submittedUrl;

  // Untuk upload file hasil kerja
  String? _pickedFileName;
  String? _uploadedResultUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchRefFiles();
  }

  // ── PERUBAHAN 2: _fetchRefFiles() diubah total ─────────────
  // Sebelumnya: query ke tabel 'deliverables' kolom file_url + catatan
  // Sekarang:   query ke tabel 'orders' kolom requirement_file_url/name + requirement_image_url/name
  Future<void> _fetchRefFiles() async {
    try {
      final orderId = int.tryParse(widget.order.id) ?? 0;
      final res = await _supabase
          .from('orders')
          .select(
            'requirement_file_url, requirement_file_name, '
            'requirement_image_url, requirement_image_name',
          )
          .eq('id_order', orderId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _refFiles = res != null
              ? [
                  _RefFile(
                    fileUrl: res['requirement_file_url']?.toString(),
                    fileName: res['requirement_file_name']?.toString(),
                    imageUrl: res['requirement_image_url']?.toString(),
                    imageName: res['requirement_image_name']?.toString(),
                  ),
                ]
              : [];
          _loadingRef = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRef = false);
    }
  }

  // ── Open URL ───────────────────────────────────────────────
  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      _snack('URL tidak valid', bg: Colors.red);
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _snack('Gagal membuka file', bg: Colors.red);
  }

  // ── Pick & Upload hasil kerja ke Supabase ──────────────────
  Future<void> _pickResultFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.any,
      );
    } catch (e) {
      _snack('Gagal membuka file picker: $e', bg: Colors.red);
      return;
    }
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) {
      _snack('File tidak terbaca', bg: Colors.red);
      return;
    }

    setState(() {
      _isUploading = true;
      _pickedFileName = file.name;
    });

    try {
      final uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storagePath = 'results/${widget.order.id}/$uniqueName';

      await _supabase.storage
          .from('deliverables')
          .uploadBinary(
            storagePath,
            file.bytes!,
            fileOptions: const FileOptions(
              contentType: 'application/octet-stream',
              upsert: false,
            ),
          );

      final url = _supabase.storage
          .from('deliverables')
          .getPublicUrl(storagePath);

      if (mounted) setState(() => _uploadedResultUrl = url);
      _snack('File berhasil diupload ✓');
    } catch (e) {
      _snack('Gagal upload: $e', bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Submit hasil kerja ke Laravel ──────────────────────────
  Future<void> _submitResult() async {
    if (_uploadedResultUrl == null) {
      _snack('Upload file hasil kerja terlebih dahulu');
      return;
    }
    if (_isSubmitting) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Kirim Hasil Kerja?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'File hasil kerja akan dikirimkan ke client. '
          'Pastikan file sudah sesuai dengan permintaan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _orange),
            child: const Text(
              'Ya, Kirim',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      final orderId = int.tryParse(widget.order.id) ?? 0;

      await _supabase.from('deliverables').insert({
        'id_order': orderId,
        'file_url': _uploadedResultUrl,
        'catatan': 'Hasil kerja freelancer',
      });

      await _supabase
          .from('orders')
          .update({
            'status': 'hasil_dikirim',
            'result_file_url': _uploadedResultUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_order', orderId);

      if (!mounted) return;

      setState(() => _submittedUrl = _uploadedResultUrl);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Color(0xFF2196F3),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hasil Dikirim!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'File hasil kerja berhasil dikirimkan ke client.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke My Orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _snack('❌ ${e.toString()}', bg: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg, {Color bg = const Color(0xFFFFA726)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool canSubmit = ['paid', 'diproses'].contains(order.status);
    final bool alreadySent =
        order.status == 'hasil_dikirim' ||
        order.status == 'revisi' ||
        order.status == 'selesai';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ──────────────────────────────────────
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Order Detail',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ORDER INFO CARD ───────────────────────
                    _card(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildAvatar(
                                  order.freelancerAvatar,
                                  80,
                                  80,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.serviceName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.freelancerName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      order.price == '-'
                                          ? _rupiah(order.packagePrice)
                                          : order.price,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _statusBadge(order.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, thickness: 0.5),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _infoBlock('Order ID', '#${order.id}'),
                              ),
                              Expanded(
                                child: _infoBlock(
                                  'Deadline',
                                  _formatDeadline(order.deadline),
                                ),
                              ),
                              Expanded(
                                child: _infoBlock(
                                  'Status Detail',
                                  _rawStatusLabel(order.status),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── NOTE ──────────────────────────────────
                    if (order.note.trim().isNotEmpty)
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catatan dari Client',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.note,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (order.note.trim().isNotEmpty)
                      const SizedBox(height: 14),

                    // ── FILE REFERENSI CLIENT ──────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'File Referensi Client',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_loadingRef)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFFA726),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'File yang diupload client sebagai referensi pengerjaan',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── PERUBAHAN 3: render file referensi diubah ──
                          // Sebelumnya: ..._refFiles.map((f) => _refFileItem(f))
                          // Sekarang:   cek fileUrl dan imageUrl secara terpisah
                          if (!_loadingRef &&
                              (_refFiles.isEmpty ||
                                  ((_refFiles.first.fileUrl ?? '').isEmpty &&
                                      (_refFiles.first.imageUrl ?? '')
                                          .isEmpty)))
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 32,
                                    color: Colors.black26,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tidak ada file referensi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_refFiles.isNotEmpty) ...[
                            // Tampilkan dokumen jika ada
                            if ((_refFiles.first.fileUrl ?? '').isNotEmpty)
                              _refFileItem(
                                url: _refFiles.first.fileUrl!,
                                label:
                                    _refFiles.first.fileName ??
                                    'Dokumen referensi',
                                isImage: false,
                              ),
                            // Tampilkan gambar jika ada
                            if ((_refFiles.first.imageUrl ?? '').isNotEmpty)
                              _refFileItem(
                                url: _refFiles.first.imageUrl!,
                                label:
                                    _refFiles.first.imageName ??
                                    'Gambar referensi',
                                isImage: true,
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── PENYERAHAN HASIL KERJA ─────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kirim Hasil Kerja',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alreadySent
                                ? 'Hasil kerja sudah dikirimkan ke client.'
                                : 'Upload file hasil kerja dan kirim ke client.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (alreadySent)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      order.status == 'selesai'
                                          ? 'Pesanan selesai. Dana telah dicairkan.'
                                          : order.status == 'revisi'
                                          ? 'Client meminta revisi. Upload ulang di bawah.'
                                          : 'Hasil kerja sudah terkirim. Menunggu konfirmasi client.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF388E3C),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (canSubmit || order.status == 'revisi') ...[
                            if (alreadySent) const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _isUploading ? null : _pickResultFile,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: _uploadedResultUrl != null
                                      ? const Color(0xFFE8F5E9)
                                      : _softPurple,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _uploadedResultUrl != null
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFFADB5FF),
                                    width: 1.4,
                                  ),
                                ),
                                child: _isUploading
                                    ? const Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: _purple,
                                            strokeWidth: 2.5,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Mengupload...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _purple,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Icon(
                                            _uploadedResultUrl != null
                                                ? Icons.check_circle_rounded
                                                : Icons.cloud_upload_rounded,
                                            size: 32,
                                            color: _uploadedResultUrl != null
                                                ? const Color(0xFF4CAF50)
                                                : _purple,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _uploadedResultUrl != null
                                                ? (_pickedFileName ??
                                                      'File terupload ✓')
                                                : 'Tap untuk upload file hasil kerja',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _uploadedResultUrl != null
                                                  ? const Color(0xFF388E3C)
                                                  : _purple,
                                            ),
                                          ),
                                          if (_uploadedResultUrl == null)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                'PDF, DOC, ZIP, PSD, atau format lainnya',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black38,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed:
                                    (_isSubmitting ||
                                        _isUploading ||
                                        _uploadedResultUrl == null)
                                    ? null
                                    : _submitResult,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _orange,
                                  disabledBackgroundColor: _orange.withOpacity(
                                    0.45,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                label: Text(
                                  _isSubmitting
                                      ? 'Mengirim...'
                                      : order.status == 'revisi'
                                      ? 'Kirim Ulang Hasil Revisi'
                                      : 'Kirim Hasil ke Client',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (order.status == 'selesai' && !canSubmit) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '🎉 Pesanan telah selesai. Dana sudah dicairkan ke akunmu.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── CONTACT CLIENT BUTTON ──────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _snack('TODO: buka halaman chat client'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _orange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          foregroundColor: _orange,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text(
                          'Contact Client',
                          style: TextStyle(
                            fontSize: 14,
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

  // ── Widget Helpers ─────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _buildAvatar(String url, double w, double h) {
    final isNet = url.startsWith('http');
    return Container(
      width: w,
      height: h,
      color: Colors.grey.shade200,
      child: url.isEmpty
          ? const Icon(Icons.person, color: Colors.grey)
          : isNet
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: Colors.grey),
            )
          : Image.asset(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: Colors.grey),
            ),
    );
  }

  Widget _infoBlock(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  );

  // ── PERUBAHAN 4: _refFileItem() signature diubah ───────────
  // Sebelumnya: menerima _RefFile object → pakai f.url dan f.catatan
  // Sekarang:   menerima url, label, isImage secara langsung (named parameters)
  Widget _refFileItem({
    required String url,
    required String label,
    required bool isImage,
  }) {
    final ext = url.split('.').last.split('?').first.toUpperCase();

    final extColor =
        const {
          'PDF': Color(0xFFE53935),
          'DOC': Color(0xFF1E88E5),
          'DOCX': Color(0xFF1E88E5),
          'ZIP': Color(0xFF8E24AA),
          'RAR': Color(0xFF8E24AA),
          'PSD': Color(0xFF00ACC1),
          'AI': Color(0xFFF4511E),
          'FIG': Color(0xFF43A047),
          'TXT': Color(0xFF757575),
        }[ext] ??
        const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  url,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _extBadge(ext, extColor),
                ),
              )
            else
              _extBadge(ext, extColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isImage ? 'Gambar referensi' : 'Dokumen referensi',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _extBadge(String ext, Color color) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        ext.length > 4 ? ext.substring(0, 4) : ext,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ),
  );

  Widget _statusBadge(String status) {
    Color bg, text;
    String label;
    switch (status) {
      case 'menunggu_pembayaran':
        bg = const Color(0xFFFFF3E0);
        text = const Color(0xFFFF9800);
        label = 'Pending';
        break;
      case 'paid':
      case 'diproses':
        bg = const Color(0xFFE3F2FD);
        text = const Color(0xFF2196F3);
        label = 'In Progress';
        break;
      case 'hasil_dikirim':
        bg = const Color(0xFFF3E5F5);
        text = const Color(0xFF8E24AA);
        label = 'Delivered';
        break;
      case 'revisi':
        bg = Colors.orange.withOpacity(0.15);
        text = Colors.orange[800]!;
        label = 'Revision';
        break;
      case 'selesai':
        bg = Colors.green.withOpacity(0.15);
        text = Colors.green[700]!;
        label = 'Done';
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  String _rawStatusLabel(String status) {
    const map = {
      'menunggu_pembayaran': 'Menunggu Bayar',
      'paid': 'Dibayar',
      'diproses': 'Diproses',
      'hasil_dikirim': 'Hasil Dikirim',
      'revisi': 'Revisi',
      'selesai': 'Selesai',
      'dibatalkan': 'Dibatalkan',
      'pembayaran_gagal': 'Bayar Gagal',
      'failed': 'Failed',
      'expired': 'Expired',
    };
    return map[status] ?? status;
  }

  String _rupiah(double val) => 'Rp ${_fmtNum(val)}';

  String _fmtNum(double val) {
    final s = val.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  String _formatDeadline(String deadline) {
    if (deadline.trim().isEmpty || deadline == '-') return '-';
    try {
      final date = DateTime.parse(deadline.trim());
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return deadline;
    }
  }
}
