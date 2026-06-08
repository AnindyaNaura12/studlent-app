// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/custom_back_button.dart';
import '../../controllers/my_services_controller.dart';
import '../../models/service_category_model.dart';

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

  int? _selectedCategoryId;
  int _selectedPackageTab = 0;
  bool _loading = false;
  bool _loadingCategories = false;

  List<ServiceCategory> _categories = [];

  Uint8List? _imageBytes;
  String? _imageMimeType;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

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

  String get _currentPackageKey {
    if (_selectedPackageTab == 0) return 'basic';
    if (_selectedPackageTab == 1) return 'standard';
    return 'premium';
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);

    try {
      await widget.controller.fetchCategories();

      if (!mounted) return;

      debugPrint('TOTAL CATEGORY: ${widget.controller.categories.length}');
      for (final c in widget.controller.categories) {
        debugPrint('CATEGORY => ${c.id} | ${c.name}');
      }

      setState(() {
        _categories = widget.controller.categories;
      });
    } catch (e) {
      debugPrint('ERROR LOAD CATEGORIES: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

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

  Future<void> _onRequestPressed() async {
  if (_titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service title wajib diisi')),
    );
    return;
  }

  if (_selectedCategoryId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service category wajib dipilih')),
    );
    return;
  }

  // Validasi: semua paket wajib diisi harganya
  final packageKeys = ['basic', 'standard', 'premium'];
  for (final key in packageKeys) {
    final price = _packageControllers[key]!['price']!.text.trim();
    if (price.isEmpty) {
      // Arahkan tab ke paket yang belum diisi
      final tabIndex = packageKeys.indexOf(key);
      setState(() => _selectedPackageTab = tabIndex);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harga paket ${key[0].toUpperCase()}${key.substring(1)} wajib diisi',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  setState(() => _loading = true);

  try {
    // 1. Dapatkan id_user dari controller (tetap di controller, bukan query ulang)
    final currentUserId = await widget.controller.getCurrentUserId();

    if (currentUserId == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User belum login'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Upload gambar jika ada (tetap di View karena menyentuh _imageBytes)
    String? thumbnailUrl;
    if (_imageBytes != null) {
      thumbnailUrl = await _uploadImageToStorage();
    }

    // 3. Ambil data ketiga paket dari _packageControllers
    final basicCtrl    = _packageControllers['basic']!;
    final standardCtrl = _packageControllers['standard']!;
    final premiumCtrl  = _packageControllers['premium']!;

    // 4. Delegasikan seluruh logika DB ke controller.addService()
    final result = await widget.controller.addService(
      freelancerId : currentUserId,
      categoryId   : _selectedCategoryId!,
      title        : _titleController.text.trim(),
      description  : _descController.text.trim(),
      imageUrl     : thumbnailUrl,
      status       : 'pending',

      // Paket Basic
      basicPrice            : basicCtrl['price']!.text,
      basicDeliveryTime     : basicCtrl['delivery']!.text,
      basicShortDescription : basicCtrl['desc']!.text,

      // Paket Standard
      standardPrice            : standardCtrl['price']!.text,
      standardDeliveryTime     : standardCtrl['delivery']!.text,
      standardShortDescription : standardCtrl['desc']!.text,

      // Paket Premium
      premiumPrice            : premiumCtrl['price']!.text,
      premiumDeliveryTime     : premiumCtrl['delivery']!.text,
      premiumShortDescription : premiumCtrl['desc']!.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      widget.onServiceAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The service request has been submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add service. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _buildLabel('Service Title'),
              _buildTextField(
                controller: _titleController,
                hint: 'Enter service title',
              ),
              const SizedBox(height: 12),

              _buildLabel('Service Category'),
              _buildDropdown(),
              const SizedBox(height: 12),

              _buildLabel('Service Image'),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'Upload service preview image',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA8A8A8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _buildImagePicker(),
              const SizedBox(height: 12),

              _buildLabel('Service Description'),
              _buildDescriptionField(),
              const SizedBox(height: 16),

              const Text(
                'Pricing & Packages',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Enter price & details for each package',
                style: TextStyle(fontSize: 10, color: Color(0xFFA8A8A8)),
              ),
              const SizedBox(height: 10),
              _buildPackageTabs(),
              const SizedBox(height: 10),
              _buildPricingSection(),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 31,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF7D7D7D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 31,
                    decoration: BoxDecoration(
                      color: _loading
                          ? const Color(0xFFE0E0E0)
                          : const Color(0xFFF4B544),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _loading ? null : _onRequestPressed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Request',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _uploadingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD8D8D8), width: 1),
        ),
        child: _uploadingImage
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFBDBDBD),
                ),
              )
            : _imageBytes != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _imageBytes!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Change',
                            style: TextStyle(fontSize: 11, color: Colors.white),
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
                    size: 30,
                    color: const Color(0xFFC6C6C6),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to select image',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9F9F9F)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'JPG, PNG, WEBP',
                    style: TextStyle(fontSize: 9, color: Color(0xFFC3C3C3)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
      ),
      child: _loadingCategories
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Loading categories...',
                style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
              ),
            )
          : _categories.isEmpty
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Category not available',
                style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedCategoryId,
                isExpanded: true,
                hint: const Text(
                  'Select category',
                  style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF7C7C7C),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
      ),
      child: TextField(
        controller: _descController,
        maxLines: 5,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Describe your service in detail...',
          hintStyle: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildPackageTabs() {
    final tabs = ['Basic', 'Standard', 'Premium'];

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF2DE99),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedPackageTab == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPackageTab = i),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE1BC4C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: const Color(0xFF5B4B1F),
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
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package $packageName',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Price (Rp)',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF8B8B8B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          _buildPriceField(ctrlMap['price']!),
          const SizedBox(height: 10),
          const Text(
            'Delivery Time (days)',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF8B8B8B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          _buildDeliveryField(ctrlMap['delivery']!),
          const SizedBox(height: 10),
          const Text(
            'Package Description',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF8B8B8B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
            ),
            child: TextField(
              controller: ctrlMap['desc']!,
              maxLines: 3,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'What do you get in the $packageName package?',
                hintStyle: const TextStyle(
                  color: Color(0xFFC4C4C4),
                  fontSize: 11,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(TextEditingController controller) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Example: 150000',
          hintStyle: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDeliveryField(TextEditingController controller) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Example: 3',
          hintStyle: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}
