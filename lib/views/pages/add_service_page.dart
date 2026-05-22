// ignore_for_file: deprecated_member_use
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_back_button.dart';
import '../../controllers/my_services_controller.dart';

class AddServicePage extends StatefulWidget {
  final MyServicesController controller;
  final void Function() onServiceAdded;

  const AddServicePage({
    super.key,
    required this.controller,
    required this.onServiceAdded,
  });

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final Map<String, Map<String, TextEditingController>> _packageControllers = {
    'basic': {
      'price': TextEditingController(),
      'delivery': TextEditingController(),
      'desc': TextEditingController(),
    },
    'standard': {
      'price': TextEditingController(),
      'delivery': TextEditingController(),
      'desc': TextEditingController(),
    },
    'premium': {
      'price': TextEditingController(),
      'delivery': TextEditingController(),
      'desc': TextEditingController(),
    },
  };

  String? _selectedCategory;
  int _selectedPackageTab = 0;
  bool _loading = false;

  // ── Gambar service ──────────────────────────────────────
  Uint8List? _imageBytes;
  String? _imageMimeType;
  bool _uploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final pkg in _packageControllers.values) {
      for (final ctrl in pkg.values) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  String get _currentPackageKey => _selectedPackageTab == 0
      ? 'basic'
      : _selectedPackageTab == 1
      ? 'standard'
      : 'premium';

  // ── Pick gambar ─────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      setState(() => _uploadingImage = true);
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );
      if (picked == null) {
        setState(() => _uploadingImage = false);
        return;
      }

      final bytes = await picked.readAsBytes();

      // Deteksi mimeType dari magic bytes
      String mimeType = picked.mimeType ?? '';
      if (mimeType.isEmpty || mimeType.contains('blob')) {
        if (bytes.length >= 4) {
          if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
            mimeType = 'image/jpeg';
          } else if (bytes[0] == 0x89 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x4E &&
              bytes[3] == 0x47) {
            mimeType = 'image/png';
          } else if (bytes[0] == 0x47 && bytes[1] == 0x49) {
            mimeType = 'image/gif';
          } else if (bytes[0] == 0x52 &&
              bytes[1] == 0x49 &&
              bytes[2] == 0x46 &&
              bytes[3] == 0x46) {
            mimeType = 'image/webp';
          } else {
            mimeType = 'image/jpeg';
          }
        } else {
          mimeType = 'image/jpeg';
        }
      }

      setState(() {
        _imageBytes = bytes;
        _imageMimeType = mimeType;
        _uploadingImage = false;
      });
    } catch (e) {
      setState(() => _uploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal pilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Upload gambar ke Supabase Storage ───────────────────
  Future<String?> _uploadImageToStorage() async {
    if (_imageBytes == null) return null;
    try {
      final supabase = Supabase.instance.client;
      final ext = (_imageMimeType ?? 'image/jpeg')
          .split('/')
          .last
          .replaceAll('jpeg', 'jpg');
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await supabase.storage
          .from('services')
          .uploadBinary(
            fileName,
            _imageBytes!,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _imageMimeType ?? 'image/jpeg',
            ),
          );

      return supabase.storage.from('services').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('uploadImageToStorage error: $e');
      return null;
    }
  }

  // ── Submit service ke Supabase ──────────────────────────
  Future<void> _onRequestPressed() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service title wajib diisi')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        setState(() => _loading = false);
        return;
      }

      final user = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      // Upload gambar dulu kalau ada
      String? thumbnailUrl;
      if (_imageBytes != null) {
        thumbnailUrl = await _uploadImageToStorage();
      }

      // Ambil id_category
      final categoryResult = await supabase
          .from('service_categories')
          .select('id_category')
          .eq('nama', _selectedCategory ?? '');

      final idCategory = categoryResult.isNotEmpty
          ? categoryResult[0]['id_category']
          : null;

      // Insert service
      final serviceResult = await supabase
          .from('services')
          .insert({
            'id_freelancer': user['id_user'],
            'id_category': idCategory,
            'judul': _titleController.text.trim(),
            'deskripsi': _descController.text.trim(),
            'thumbnail_url': thumbnailUrl,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final idService = serviceResult['id_service'];

      // Insert gambar ke service_images
      if (thumbnailUrl != null) {
        await supabase.from('service_images').insert({
          'id_service': idService,
          'image_url': thumbnailUrl,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Insert 3 packages
      final packages = ['basic', 'standard', 'premium'];
      for (final pkg in packages) {
        final ctrl = _packageControllers[pkg]!;
        await supabase.from('service_packages').insert({
          'id_service': idService,
          'nama': pkg,
          'harga':
              double.tryParse(
                ctrl['price']!.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0,
          'delivery_time':
              int.tryParse(
                ctrl['delivery']!.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0,
          'deskripsi': ctrl['desc']!.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      setState(() => _loading = false);
      widget.onServiceAdded();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service berhasil diajukan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Add a new service',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Service Title ──
              _buildLabel('Service Title'),

              _buildLabel('Service title'),
              _buildTextField(
                controller: _titleController,
                hint: 'Masukkan judul service',
              ),
              const SizedBox(height: 16),

              // ── Service Category ──
              _buildLabel('Service Category'),
              _buildDropdown(),
              const SizedBox(height: 16),

              // ── Service Image ──
              _buildLabel('Service Image'),
              const Text(
                'Upload gambar preview service kamu',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildImagePicker(),
              const SizedBox(height: 16),

              // ── Service Description ──
              _buildLabel('Service Description'),
              _buildDescriptionField(),
              const SizedBox(height: 24),

              // ── Pricing & Packages ──
              const Text(
                'Pricing & Packages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Isi harga & detail untuk setiap paket',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildPackageTabs(),
              const SizedBox(height: 16),
              _buildPricingSection(),
              const SizedBox(height: 32),

              // ── Buttons ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _loading ? null : _onRequestPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _loading
                            ? Colors.grey.shade300
                            : const Color(0xFFFFB74D),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Request',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image Picker Widget ─────────────────────────────────
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _uploadingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: _uploadingImage
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'Memilih gambar...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            : _imageBytes != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _imageBytes!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Overlay ganti gambar
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Ganti',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap untuk pilih gambar',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, WEBP',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: Text(
            'Pilih kategori',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          items: widget.controller.categories
              .map<DropdownMenuItem<String>>(
                (String cat) =>
                    DropdownMenuItem<String>(value: cat, child: Text(cat)),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _descController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Jelaskan service kamu secara detail...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPackageTabs() {
    final tabs = ['Basic', 'Standard', 'Premium'];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5DFA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedPackageTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPackageTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8C060)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPricingSection() {
    final ctrlMap = _packageControllers[_currentPackageKey]!;
    final packageName =
        _currentPackageKey[0].toUpperCase() + _currentPackageKey.substring(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paket $packageName',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),

          // Harga
          const Text(
            'Harga (Rp)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          _buildPriceField(ctrlMap['price']!),
          const SizedBox(height: 14),

          // Delivery time
          const Text(
            'Delivery Time (hari)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          _buildDeliveryField(ctrlMap['delivery']!),
          const SizedBox(height: 14),

          // Deskripsi paket
          const Text(
            'Deskripsi Paket',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: ctrlMap['desc']!,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Apa yang didapat di paket $packageName?',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Contoh: 150000',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixText: 'Rp ',
          prefixStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Contoh: 3',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          suffixText: ' hari',
          suffixStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
