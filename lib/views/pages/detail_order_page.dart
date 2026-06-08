// lib/views/pages/detail_order_page.dart
// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../config.dart';
import '../../models/services_model.dart';
import 'payment_webview_page.dart';

class DetailOrderPage extends StatefulWidget {
  final ServiceModel service;
  final PackageModel? selectedPackage;

  const DetailOrderPage({
    super.key,
    required this.service,
    this.selectedPackage,
  });

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  String? _selectedPayment;
  final TextEditingController _noteController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isProcessing = false;
  bool _isUploading = false;

  final List<_UploadedFile> _uploadedFiles = [];

  // ── Payment Methods ────────────────────────────────────────
  // 'value' = kode Midtrans, 'label' = tampilan ke user
  final List<Map<String, dynamic>> _eWalletMethods = [
    {'label': 'Shopeepay', 'value': 'shopeepay', 'activated': true},
    {'label': 'Gopay', 'value': 'gopay', 'activated': true},
    {'label': 'DANA', 'value': 'dana', 'activated': false},
    {'label': 'OVO', 'value': 'ovo', 'activated': false},
  ];

  final List<Map<String, dynamic>> _bankMethods = [
    {'label': 'BRI', 'value': 'bri_va', 'activated': true},
    {'label': 'BCA', 'value': 'bca_va', 'activated': true},
    {'label': 'BNI', 'value': 'bni_va', 'activated': true},
    {'label': 'Mandiri', 'value': 'echannel', 'activated': true},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Package helpers ────────────────────────────────────────
  PackageModel get _activePackage =>
      widget.selectedPackage ?? widget.service.basicPackage;

  double get _packagePrice {
    final raw = _activePackage.price
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(raw) ?? 0;
  }

  String get _packageLabel {
    final n = _activePackage.name.toString();
    if (n.isEmpty) return 'Basic';
    return '${n[0].toUpperCase()}${n.substring(1)}';
  }

  String get _deliveryTime => _activePackage.deliveryTime;

  int? get _packageId => widget.selectedPackage?.id ?? widget.service.packageId;

  // ── File Upload ────────────────────────────────────────────
  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.any,
      );
    } catch (e) {
      _showSnack('Gagal membuka file picker: $e', isError: true);
      return;
    }
    if (result == null || result.files.isEmpty) return;

    const allowed = [
      'pdf',
      'doc',
      'docx',
      'txt',
      'zip',
      'rar',
      'psd',
      'ai',
      'fig',
    ];
    final valid = result.files.where((f) {
      if (f.bytes == null) return false;
      return allowed.contains(f.name.split('.').last.toLowerCase());
    }).toList();

    if (valid.isEmpty) {
      _showSnack(
        'Format tidak didukung. Gunakan: PDF, DOC, DOCX, ZIP, dll.',
        isError: false,
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      for (final f in valid) {
        await _uploadFile(name: f.name, bytes: f.bytes!, isImage: false);
      }
    } catch (e) {
      _showSnack('Gagal upload: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.image,
      );
    } catch (e) {
      _showSnack('Gagal membuka galeri: $e', isError: true);
      return;
    }
    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      for (final f in result.files.where((f) => f.bytes != null)) {
        await _uploadFile(name: f.name, bytes: f.bytes!, isImage: true);
      }
    } catch (e) {
      _showSnack('Gagal upload gambar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadFile({
    required String name,
    required Uint8List bytes,
    required bool isImage,
  }) async {
    final ext = name.split('.').last.toLowerCase();
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$name';
    final storagePath = 'order_files/$uniqueName';

    await _supabase.storage
        .from('deliverables')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: isImage ? 'image/$ext' : 'application/octet-stream',
            upsert: false,
          ),
        );

    final url = _supabase.storage
        .from('deliverables')
        .getPublicUrl(storagePath);

    if (mounted) {
      setState(
        () => _uploadedFiles.add(
          _UploadedFile(
            name: name,
            url: url,
            isImage: isImage,
            storagePath: storagePath,
            bytes: bytes,
          ),
        ),
      );
    }
  }

  Future<void> _removeFile(int index) async {
    try {
      await _supabase.storage.from('deliverables').remove([
        _uploadedFiles[index].storagePath,
      ]);
    } catch (_) {}
    if (mounted) setState(() => _uploadedFiles.removeAt(index));
  }

  // ── Confirm & Pay ──────────────────────────────────────────
  // FLOW BARU:
  // 1. Ambil data user dari Supabase
  // 2. Kirim semua data ke Laravel → Laravel yang insert order + payment + hit Midtrans
  // 3. Laravel return payment_url + order_id
  // 4. Flutter upload file referensi ke Supabase (pakai order_id dari Laravel)
  // 5. Buka WebView
  // Order TIDAK diinsert dari Flutter — hanya dari Laravel
  Future<void> _handleConfirmPay(
    double packagePrice,
    double adminFee,
    double total,
  ) async {
    if (_selectedPayment == null) {
      _showSnack('Pilih metode pembayaran terlebih dahulu', isError: false);
      return;
    }
    if (_isProcessing || _isUploading) return;

    setState(() => _isProcessing = true);

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login ulang.');
      }

      final userData = await _supabase
          .from('users')
          .select('id_user, nama, email, no_hp')
          .eq('email', currentUser.email!)
          .maybeSingle();
      if (userData == null) throw Exception('Data pengguna tidak ditemukan.');

      final int clientId = userData['id_user'] as int;
      final int serviceId = int.tryParse(widget.service.id.toString()) ?? widget.service.id as int;

      int freelancerId;
      if (widget.service.freelancerId != null &&
          widget.service.freelancerId! > 0) {
        freelancerId = widget.service.freelancerId!;
      } else {
        final sd = await _supabase
            .from('services')
            .select('id_freelancer')
            .eq('id_service', serviceId)
            .maybeSingle();
        if (sd == null || sd['id_freelancer'] == null) {
          throw Exception('Data freelancer tidak ditemukan.');
        }
        freelancerId = sd['id_freelancer'] as int;
      }

      final deliveryDays =
          int.tryParse(_deliveryTime.replaceAll(RegExp(r'[^0-9]'), '')) ?? 3;
      final deadline = DateTime.now()
          .add(Duration(days: deliveryDays))
          .toIso8601String()
          .split('T')[0];

      // Kirim semua data ke Laravel
      // Laravel yang insert order + payment + escrow + hit Midtrans
      final apiResponse = await http
          .post(
            Uri.parse('${Config.laravelBaseUrl}/payment/initiate'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'client_id': clientId,
              'freelancer_id': freelancerId,
              'service_id': serviceId,
              'package_id': _packageId,
              'service_name': widget.service.title,
              'package_name': _packageLabel,
              'catatan': _noteController.text.trim(),
              'deadline': deadline,
              'amount': total.toInt(),
              'admin_fee': adminFee.toInt(),
              'package_price': packagePrice.toInt(),
              'payment_method': _selectedPayment,
              'customer': {
                'name': userData['nama'] ?? 'Client',
                'email': userData['email'] ?? '',
                'phone': userData['no_hp'] ?? '',
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (apiResponse.statusCode != 200) {
        final err = jsonDecode(apiResponse.body);
        throw Exception(err['message'] ?? 'Gagal membuat transaksi');
      }

      final apiData = jsonDecode(apiResponse.body);
      final paymentUrl = apiData['payment_url']?.toString() ?? '';
      final int orderId = apiData['order_id'] as int;

      if (paymentUrl.isEmpty) throw Exception('Payment URL tidak ditemukan.');

      // Upload file referensi ke Supabase pakai order_id dari Laravel
      if (_uploadedFiles.isNotEmpty) {
        await _supabase
            .from('deliverables')
            .insert(
              _uploadedFiles
                  .map(
                    (f) => {
                      'id_order': orderId,
                      'file_url': f.url,
                      'catatan': f.isImage
                          ? 'Referensi gambar'
                          : 'File referensi',
                    },
                  )
                  .toList(),
            );
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(
            paymentUrl: paymentUrl,
            orderId: orderId,
            amount: total,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _showSnack('❌ ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const double adminFee = 2500;
    final double total = _packagePrice + adminFee;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // TOP BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
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
                          const Text(
                            'Detail Order',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // SERVICE INFO
                          _buildCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      (widget.service.imagePath?.startsWith(
                                            'http',
                                          ) ??
                                          false)
                                      ? Image.network(
                                          widget.service.imagePath!,
                                          width: 110,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imgPlaceholder(),
                                        )
                                      : _imgPlaceholder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.service.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFFA726,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFFA726),
                                          ),
                                        ),
                                        child: Text(
                                          '$_packageLabel Package',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFFFFA726),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$_deliveryTime delivery',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${widget.service.category} | ${widget.service.university}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            widget.service.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFA726),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          Text(
                                            ' ${widget.service.rating}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // PRICE SUMMARY
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price Summary',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildPriceRow(
                                  '$_packageLabel package',
                                  'Rp ${_fmt(_packagePrice)}',
                                ),
                                const SizedBox(height: 4),
                                _buildPriceRow(
                                  'Admin fee',
                                  'Rp ${_fmt(adminFee)}',
                                ),
                                const Divider(height: 16),
                                _buildPriceRow(
                                  'Total',
                                  'Rp ${_fmt(total)}',
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // FILE REQUIREMENT
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'File Requirement',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_isUploading)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFFFA726),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Upload file referensi agar freelancer mengerti kebutuhanmu',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _uploadBtn(
                                      icon: Icons.attach_file,
                                      label: 'File',
                                      onTap: _isUploading
                                          ? null
                                          : _pickAndUploadFile,
                                    ),
                                    const SizedBox(width: 10),
                                    _uploadBtn(
                                      icon: Icons.image_outlined,
                                      label: 'Gambar',
                                      onTap: _isUploading
                                          ? null
                                          : _pickAndUploadImage,
                                    ),
                                  ],
                                ),
                                if (_uploadedFiles.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  if (_uploadedFiles.any((f) => f.isImage)) ...[
                                    const Text(
                                      'Gambar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _uploadedFiles
                                          .where((f) => f.isImage)
                                          .map((f) => _imagePreview(f))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (_uploadedFiles.any(
                                    (f) => !f.isImage,
                                  )) ...[
                                    const Text(
                                      'Dokumen',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ..._uploadedFiles
                                        .where((f) => !f.isImage)
                                        .map((f) => _filePreview(f)),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // NOTE
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Note',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _noteController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Jelaskan kebutuhan spesifik kamu...',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // PAYMENT METHODS
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment methods',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'E - Wallet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ..._eWalletMethods.map(_paymentItem),
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_outlined,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Bank Transfer',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ..._bankMethods.map(_paymentItem),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM BUTTON
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_isProcessing || _isUploading)
                          ? null
                          : () => _handleConfirmPay(
                              _packagePrice,
                              adminFee,
                              total,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        disabledBackgroundColor: const Color(0xFFFFD49E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: (_isProcessing || _isUploading)
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Confirm & Pay  •  Rp ${_fmt(total)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "*By clicking the button, you agree to Studlent's Terms of Service.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget Helpers ─────────────────────────────────────────
  Widget _imgPlaceholder() => Container(
    width: 110,
    height: 100,
    color: Colors.grey[200],
    child: const Icon(Icons.image, color: Colors.grey),
  );

  Widget _uploadBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: onTap == null ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: onTap == null ? Colors.grey : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: onTap == null ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(_UploadedFile f) {
    final index = _uploadedFiles.indexOf(f);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: f.bytes != null
              ? Image.memory(f.bytes!, width: 90, height: 90, fit: BoxFit.cover)
              : Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeFile(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filePreview(_UploadedFile f) {
    final index = _uploadedFiles.indexOf(f);
    final ext = f.name.split('.').last.toUpperCase();
    final color =
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                ext,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Uploaded ✓',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeFile(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );

  Widget _paymentItem(Map<String, dynamic> method) {
    final bool activated = method['activated'] as bool? ?? false;
    final String label = method['label']?.toString() ?? '';
    final String value = method['value']?.toString() ?? '';
    final bool isSelected = _selectedPayment == value;

    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black),
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (method['balance'] != null)
                    TextSpan(
                      text: ' (${method['balance']})',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (activated)
            GestureDetector(
              onTap: () => setState(() => _selectedPayment = value),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFA726)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFA726),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFA726)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Activate',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFFFA726),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(double price) {
    final s = price.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}

class _UploadedFile {
  final String name;
  final String url;
  final bool isImage;
  final String storagePath;
  final Uint8List? bytes;

  _UploadedFile({
    required this.name,
    required this.url,
    required this.isImage,
    required this.storagePath,
    this.bytes,
  });
}
