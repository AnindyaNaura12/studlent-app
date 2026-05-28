// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/services_model.dart';
import 'my_orders_page.dart';
import 'payment_webview_page.dart';

const String _laravelBaseUrl = 'http://192.168.0.109:8000/api';

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

  final List<_UploadedFile> _uploadedFiles = [];
  bool _isUploading = false;

  final List<Map<String, dynamic>> _eWalletMethods = [
    {'name': 'Shopeepay', 'balance': 'Rp200.000', 'activated': true},
    {'name': 'Gopay', 'balance': 'Rp20.000', 'activated': true},
    {'name': 'DANA', 'balance': null, 'activated': false},
    {'name': 'OVO', 'balance': null, 'activated': false},
  ];

  final List<Map<String, dynamic>> _bankMethods = [
    {'name': 'BRI', 'balance': null, 'activated': true},
    {'name': 'BCA', 'balance': null, 'activated': true},
    {'name': 'BNI', 'balance': null, 'activated': true},
    {'name': 'Mandiri', 'balance': null, 'activated': true},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ── Getters package ───────────────────────────────────────────
  double get _packagePrice {
    final pkg = widget.selectedPackage;
    if (pkg != null) {
      return double.tryParse(
            pkg.price
                .replaceAll('Rp', '')
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .trim(),
          ) ??
          0;
    }
    return double.tryParse(
          widget.service.basicPackage.price
              .replaceAll('Rp', '')
              .replaceAll('.', '')
              .replaceAll(' ', '')
              .trim(),
        ) ??
        90000;
  }

  String get _packageLabel {
    final pkg = widget.selectedPackage;
    if (pkg == null) return 'Basic';
    final n = pkg.name?.toString() ?? 'Basic';
    if (n.isEmpty) return 'Basic';
    return '${n[0].toUpperCase()}${n.substring(1)}';
  }

  String get _deliveryTime =>
      widget.selectedPackage?.deliveryTime?.toString() ??
      widget.service.basicPackage.deliveryTime?.toString() ?? '3-5 hari';

  int? get _packageId =>
      widget.selectedPackage?.id ?? widget.service.packageId;

  // ── Upload file dokumen ───────────────────────────────────────
  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,        // wajib untuk web & mobile
        type: FileType.any,    // ← ganti dari FileType.custom, hindari bug path
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka file picker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (result == null || result.files.isEmpty) return;

    // Filter ekstensi yang diizinkan secara manual
    // karena FileType.custom masih buggy di beberapa versi
    const allowedExts = [
      'pdf', 'doc', 'docx', 'txt',
      'zip', 'rar', 'psd', 'ai', 'fig',
    ];

    final validFiles = result.files.where((f) {
      if (f.bytes == null) return false;
      final ext = f.name.split('.').last.toLowerCase();
      return allowedExts.contains(ext);
    }).toList();

    if (validFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Format tidak didukung. Gunakan: PDF, DOC, DOCX, TXT, ZIP, RAR, PSD, AI, FIG',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    try {
      for (final f in validFiles) {
        await _uploadSingleFile(
          fileName: f.name,
          bytes: f.bytes!,
          isImage: false,
          localPath: '',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Upload gambar ─────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.image,  // khusus gambar saja
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka galeri: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final validImages = result.files
        .where((f) => f.bytes != null)
        .toList();

    if (validImages.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      for (final f in validImages) {
        await _uploadSingleFile(
          fileName: f.name,
          bytes: f.bytes!,
          isImage: true,
          localPath: '',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
  // ── Upload ke Supabase Storage ────────────────────────────────
  Future<void> _uploadSingleFile({
    required String fileName,
    required Uint8List bytes,
    required bool isImage,
    required String localPath,
  }) async {
    final ext = fileName.split('.').last.toLowerCase();
    final uniqueName =
        '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storagePath = 'order_files/$uniqueName';

    await _supabase.storage.from('deliverables').uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType:
                isImage ? 'image/$ext' : 'application/octet-stream',
            upsert: false,
          ),
        );

    final url =
        _supabase.storage.from('deliverables').getPublicUrl(storagePath);

    if (mounted) {
      setState(() {
        _uploadedFiles.add(_UploadedFile(
          name: fileName,
          url: url,
          isImage: isImage,
          storagePath: storagePath,
          localPath: localPath,
          bytes: bytes,
        ));
      });
    }
  }

  // ── Hapus file ────────────────────────────────────────────────
  Future<void> _removeFile(int index) async {
    final f = _uploadedFiles[index];
    try {
      await _supabase.storage
          .from('deliverables')
          .remove([f.storagePath]);
    } catch (_) {}
    if (mounted) setState(() => _uploadedFiles.removeAt(index));
  }

  // ── Confirm & Pay ─────────────────────────────────────────────
  Future<void> _handleConfirmPay(
    double packagePrice,
    double adminFee,
    double total,
  ) async {
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final service = widget.service;

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login ulang.');
      }

      final userData = await _supabase
          .from('users')
          .select('id_user, nama, email, no_hp')
          .eq('email', currentUser.email!)
          .maybeSingle();

      if (userData == null) {
        throw Exception('Data pengguna tidak ditemukan.');
      }

      final int clientId   = userData['id_user'] as int;
      final int serviceId  = int.tryParse(service.id) ?? 1;
      final int? packageId = _packageId;

      // Ambil freelancerId
      int freelancerId;
      if (service.freelancerId != null && service.freelancerId! > 0) {
        freelancerId = service.freelancerId!;
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

      final int deliveryDays = int.tryParse(
            _deliveryTime.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          3;

      final String deadline = DateTime.now()
          .add(Duration(days: deliveryDays))
          .toIso8601String()
          .split('T')[0];

      // 1. Insert order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'id_client':      clientId,
            'id_freelancer':  freelancerId,
            'id_service':     serviceId,
            'id_package':     packageId,
            'detail_pesanan': service.title,
            'catatan':        _noteController.text.trim(),
            'deadline':       deadline,
            'status':         'menunggu_pembayaran',
            'progress':       0,
          })
          .select()
          .single();

      final int orderId = orderResponse['id_order'] as int;

      // 2. Hitung fee
      const double feePercent    = 10.0;
      final double platformFee   = packagePrice * (feePercent / 100);
      final double freelancerGet = packagePrice - platformFee;

      // 3. Insert payment
      final paymentResponse = await _supabase
          .from('payments')
          .insert({
            'id_order':           orderId,
            'metode':             _selectedPayment,
            'amount':             total,
            'admin_fee':          adminFee,
            'status':             'pending',
            'escrow_status':      'hold',
            'fee_percent':        feePercent,
            'platform_fee':       platformFee,
            'freelancer_receive': freelancerGet,
          })
          .select()
          .single();

      final int paymentId = paymentResponse['id_payment'] as int;

      // 4. Insert escrow
      await _supabase.from('escrow').insert({
        'id_payment':        paymentId,
        'amount':            total,
        'platform_fee':      platformFee,
        'freelancer_amount': freelancerGet,
        'status':            'hold',
      });

      // 5. Simpan file ke deliverables
      if (_uploadedFiles.isNotEmpty) {
        await _supabase.from('deliverables').insert(
          _uploadedFiles
              .map((f) => {
                    'id_order': orderId,
                    'file_url': f.url,
                    'catatan':  f.isImage
                        ? 'Referensi gambar dari client'
                        : 'File referensi dari client',
                  })
              .toList(),
        );
      }

      // 6. Call Laravel → buat transaksi Midtrans
      final session = await _supabase.auth.currentSession;
      final token   = session?.accessToken ?? '';

     // 6. Call Laravel → buat transaksi Midtrans
      final apiResponse = await http
          .post(
            Uri.parse('$_laravelBaseUrl/payment/initiate'),
            headers: {
              'Content-Type': 'application/json',
              // ← hapus Authorization header, tidak perlu
            },
            body: jsonEncode({
              'order_id':       orderId,
              'payment_id':     paymentId,
              'amount':         total.toInt(),
              'customer': {
                'name':  userData['nama']  ?? 'Client',
                'email': userData['email'] ?? '',
                'phone': userData['no_hp'] ?? '',
              },
              'item': {
                'name':  '${service.title} - $_packageLabel Package',
                'price': total.toInt(),
                'qty':   1,
              },
              'payment_method': _selectedPayment,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (apiResponse.statusCode != 200) {
        // Tampilkan detail error dari Laravel
        final errorBody = jsonDecode(apiResponse.body);
        throw Exception(errorBody['message'] ?? errorBody['error'] ?? 'Gagal membuat transaksi');
      }

      final apiData    = jsonDecode(apiResponse.body);
      final paymentUrl = apiData['payment_url']?.toString() ?? '';

      if (paymentUrl.isEmpty) {
        throw Exception('Payment URL tidak ditemukan dari server.');
      }

      // 7. Update payment_url di Supabase
      await _supabase.from('payments').update({
        'payment_url':    paymentUrl,
        'gateway_trx_id': apiData['transaction_id'] ?? '',
      }).eq('id_payment', paymentId);

      if (!mounted) return;

      // 8. Buka WebView pembayaran
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(
            paymentUrl: paymentUrl,
            orderId:    orderId,
            amount:     total,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('❌ ${e.toString()}'),
          backgroundColor: Colors.red,
          duration:        const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const double adminFee = 2000;
    final double total    = _packagePrice + adminFee;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── TOP BAR ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                                child: const Icon(Icons.arrow_back,
                                    size: 20, color: Colors.black),
                              ),
                            ),
                          ),
                          const Text(
                            'Detail Order',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // ── SERVICE INFO ──
                          _buildCard(
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  child: widget.service.imagePath !=
                                              null &&
                                          widget.service.imagePath!
                                              .startsWith('http')
                                      ? Image.network(
                                          widget.service.imagePath ?? '',
                                          width: 110,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
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
                                        widget.service.title ?? '',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFA726)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: const Color(
                                                  0xFFFFA726)),
                                        ),
                                        child: Text(
                                          '$_packageLabel Package',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFFFA726),
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$_deliveryTime delivery',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${widget.service.category ?? '_'} | ${widget.service.university ?? '_'}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            widget.service.name ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFA726),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.star,
                                              color: Colors.amber,
                                              size: 14),
                                          Text(
                                            ' ${widget.service.rating}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.bold),
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

                          // ── PRICE SUMMARY ──
                          _buildCard(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Price Summary',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                _buildPriceRow(
                                  '$_packageLabel package',
                                  'Rp ${_formatPrice(_packagePrice)}',
                                ),
                                const SizedBox(height: 4),
                                _buildPriceRow(
                                  'Admin fee',
                                  'Rp ${_formatPrice(adminFee)}',
                                ),
                                const Divider(height: 16),
                                _buildPriceRow(
                                  'Total',
                                  'Rp ${_formatPrice(total)}',
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── FILE REQUIREMENT ──
                          _buildCard(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'File Requirement',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
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
                                      color: Colors.black54),
                                ),
                                const SizedBox(height: 12),

                                // Tombol upload
                                Row(
                                  children: [
                                    _uploadButton(
                                      icon: Icons.attach_file,
                                      label: 'File',
                                      onTap: _isUploading
                                          ? null
                                          : _pickAndUploadFile,
                                    ),
                                    const SizedBox(width: 10),
                                    _uploadButton(
                                      icon: Icons.image_outlined,
                                      label: 'Gambar',
                                      onTap: _isUploading
                                          ? null
                                          : _pickAndUploadImage,
                                    ),
                                  ],
                                ),

                                // Preview area
                                if (_uploadedFiles.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),

                                  // Grid gambar
                                  if (_uploadedFiles
                                      .any((f) => f.isImage)) ...[
                                    const Text(
                                      'Gambar',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _uploadedFiles
                                          .where((f) => f.isImage)
                                          .map((f) =>
                                              _buildImagePreview(f))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // List dokumen
                                  if (_uploadedFiles
                                      .any((f) => !f.isImage)) ...[
                                    const Text(
                                      'Dokumen',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                    const SizedBox(height: 8),
                                    ..._uploadedFiles
                                        .where((f) => !f.isImage)
                                        .map((f) =>
                                            _buildFilePreview(f))
                                        .toList(),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── NOTE ──
                          _buildCard(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Note',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _noteController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Jelaskan kebutuhan spesifik kamu...',
                                    hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 13),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style:
                                      const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── PAYMENT METHODS ──
                          _buildCard(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Payment methods',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 14),

                                // E-Wallet
                                const Row(children: [
                                  Icon(
                                      Icons
                                          .account_balance_wallet_outlined,
                                      size: 22,
                                      color: Colors.black87),
                                  SizedBox(width: 8),
                                  Text('E - Wallet',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ]),
                                const SizedBox(height: 8),
                                ..._eWalletMethods
                                    .map((m) => _buildPaymentItem(m)),

                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                // Bank Transfer
                                const Row(children: [
                                  Icon(
                                      Icons.account_balance_outlined,
                                      size: 22,
                                      color: Colors.black87),
                                  SizedBox(width: 8),
                                  Text('Bank Transfer',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ]),
                                const SizedBox(height: 8),
                                ..._bankMethods
                                    .map((m) => _buildPaymentItem(m)),
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

            // ── BOTTOM CONFIRM BUTTON ──
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
                              _packagePrice, adminFee, total),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        disabledBackgroundColor:
                            const Color(0xFFFFD49E),
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
                                  strokeWidth: 2.5),
                            )
                          : Text(
                              'Confirm & Pay  •  Rp ${_formatPrice(total)}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "*By clicking the button, you agree to Studlent's Terms of Service.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WIDGET HELPERS
  // ─────────────────────────────────────────────────────────────

  Widget _imgPlaceholder() => Container(
        width: 110,
        height: 100,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      );

  Widget _uploadButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: onTap == null ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 20,
                color: onTap == null ? Colors.grey : Colors.black87),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: onTap == null
                        ? Colors.grey
                        : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(_UploadedFile f) {
    final index = _uploadedFiles.indexOf(f);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: f.bytes != null
              ? Image.memory(
                  f.bytes!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image,
                      color: Colors.grey),
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
              child: const Icon(Icons.close,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(_UploadedFile f) {
    final index = _uploadedFiles.indexOf(f);
    final ext = f.name.split('.').last.toUpperCase();

    final Color badgeColor = {
          'PDF':  const Color(0xFFE53935),
          'DOC':  const Color(0xFF1E88E5),
          'DOCX': const Color(0xFF1E88E5),
          'ZIP':  const Color(0xFF8E24AA),
          'RAR':  const Color(0xFF8E24AA),
          'PSD':  const Color(0xFF00ACC1),
          'AI':   const Color(0xFFF4511E),
          'FIG':  const Color(0xFF43A047),
          'TXT':  const Color(0xFF757575),
        }[ext] ??
        Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
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
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                ext,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
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
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Uploaded ✓',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade600),
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
              child: Icon(Icons.delete_outline,
                  size: 18, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
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
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? Colors.black : Colors.black54)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black)),
      ],
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> method) {
    final bool isActivated = method['activated'] as bool ?? false;
    final String methodName =
    method['name']?.toString() ?? '';

    final bool isSelected =
        _selectedPayment == methodName;

    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 13, color: Colors.black),
                children: [
                  TextSpan(
                      text: methodName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500)),
                  if (method['balance'] != null)
                    TextSpan(
                        text: ' (${method['balance']})',
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12)),
                ],
              ),
            ),
          ),
          if (isActivated)
            GestureDetector(
              onTap: () =>
                  setState(() => _selectedPayment = methodName),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFA726)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Activate',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFA726),
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final formatted = price.toInt().toString();
    final result    = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(formatted[i]);
      count++;
    }
    return result.toString().split('').reversed.join();
  }
}

// ── Model internal ────────────────────────────────────────────
class _UploadedFile {
  final String     name;
  final String     url;
  final bool       isImage;
  final String     storagePath;
  final String     localPath;
  final Uint8List? bytes;

  _UploadedFile({
    required this.name,
    required this.url,
    required this.isImage,
    required this.storagePath,
    required this.localPath,
    this.bytes,
  });
}