import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_back_button.dart';
import '../../models/services_model.dart';
import '../../models/service_category_model.dart';
import '../../controllers/my_services_controller.dart';

class EditServicePage extends StatefulWidget {
  final ServiceModel service;
  final MyServicesController controller;
  final void Function() onServiceUpdated;

  const EditServicePage({
    super.key,
    required this.service,
    required this.controller,
    required this.onServiceUpdated,
  });

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _deliveryController;
  late TextEditingController _shortDescController;

  final ImagePicker _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  int? _selectedCategoryId;
  int _selectedPackageTab = 0;
  List<String> _serviceImages = [];
  bool _loadingCategories = false;
  bool _saving = false;
  bool _uploadingImage = false;

  List<ServiceCategory> _categories = [];

  late Map<String, String> _basicPackageData;
  late Map<String, String> _standardPackageData;
  late Map<String, String> _premiumPackageData;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.service.title);
    _descController = TextEditingController(text: widget.service.description);

    _basicPackageData = {
      'price': widget.service.basicPackage.price,
      'deliveryTime': widget.service.basicPackage.deliveryTime,
      'shortDescription': widget.service.basicPackage.shortDescription,
    };

    _standardPackageData = {
      'price': widget.service.standardPackage?.price ?? '',
      'deliveryTime': widget.service.standardPackage?.deliveryTime ?? '',
      'shortDescription':
          widget.service.standardPackage?.shortDescription ?? '',
    };

    _premiumPackageData = {
      'price': widget.service.premiumPackage?.price ?? '',
      'deliveryTime': widget.service.premiumPackage?.deliveryTime ?? '',
      'shortDescription': widget.service.premiumPackage?.shortDescription ?? '',
    };

    _priceController = TextEditingController(
      text: _basicPackageData['price'] ?? '',
    );
    _deliveryController = TextEditingController(
      text: _basicPackageData['deliveryTime'] ?? '',
    );
    _shortDescController = TextEditingController(
      text: _basicPackageData['shortDescription'] ?? '',
    );

    _serviceImages = List<String>.from(widget.service.serviceImages);

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);

    try {
      await widget.controller.fetchCategories();

      final loadedCategories = widget.controller.categories;
      final selectedId = widget.controller.findCategoryIdByName(
        widget.service.category,
      );

      if (!mounted) return;

      setState(() {
        _categories = loadedCategories;
        _selectedCategoryId = selectedId;
      });
    } catch (e) {
      debugPrint('ERROR LOAD CATEGORIES: $e');
      _showSnackBar('Gagal memuat kategori', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _saveCurrentPackageData() {
    final currentData = {
      'price': _priceController.text.trim(),
      'deliveryTime': _deliveryController.text.trim(),
      'shortDescription': _shortDescController.text.trim(),
    };

    if (_selectedPackageTab == 0) {
      _basicPackageData = currentData;
    } else if (_selectedPackageTab == 1) {
      _standardPackageData = currentData;
    } else {
      _premiumPackageData = currentData;
    }
  }

  void _loadPackageData(int tabIndex) {
    Map<String, String> selectedData;

    if (tabIndex == 0) {
      selectedData = _basicPackageData;
    } else if (tabIndex == 1) {
      selectedData = _standardPackageData;
    } else {
      selectedData = _premiumPackageData;
    }

    _priceController.text = selectedData['price'] ?? '';
    _deliveryController.text = selectedData['deliveryTime'] ?? '';
    _shortDescController.text = selectedData['shortDescription'] ?? '';
  }

  void _changePackageTab(int newTab) {
    _saveCurrentPackageData();
    setState(() {
      _selectedPackageTab = newTab;
    });
    _loadPackageData(newTab);
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _uploadingImage = true);

      final bytes = await pickedFile.readAsBytes();
      final fileExt = pickedFile.name.split('.').last.toLowerCase();
      final fileName =
          'service_${widget.service.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'services/$fileName';

      await _supabase.storage
          .from('service-images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: pickedFile.mimeType ?? 'image/$fileExt',
            ),
          );

      final imageUrl = _supabase.storage
          .from('service-images')
          .getPublicUrl(filePath);

      if (!mounted) return;

      setState(() {
        _serviceImages.add(imageUrl);
        _uploadingImage = false;
      });

      _showSnackBar('Gambar berhasil diupload', Colors.green);
    } catch (e) {
      if (!mounted) return;

      setState(() => _uploadingImage = false);
      _showSnackBar('Gagal upload gambar: $e', Colors.red);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _deliveryController.dispose();
    _shortDescController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Title wajib diisi', Colors.red);
      return;
    }

    if (_selectedCategoryId == null) {
      _showSnackBar('Category wajib dipilih', Colors.red);
      return;
    }

    _saveCurrentPackageData();

    setState(() => _saving = true);

    try {
      final success = await widget.controller.updateService(
        idService: int.parse(widget.service.id),
        categoryId: _selectedCategoryId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        serviceImages: _serviceImages,
        basicPrice: _basicPackageData['price'],
        basicDeliveryTime: _basicPackageData['deliveryTime'],
        basicShortDescription: _basicPackageData['shortDescription'],
        standardPrice: _standardPackageData['price'],
        standardDeliveryTime: _standardPackageData['deliveryTime'],
        standardShortDescription: _standardPackageData['shortDescription'],
        premiumPrice: _premiumPackageData['price'],
        premiumDeliveryTime: _premiumPackageData['deliveryTime'],
        premiumShortDescription: _premiumPackageData['shortDescription'],
      );

      if (!mounted) return;

      setState(() => _saving = false);

      if (success) {
        widget.onServiceUpdated();
        Navigator.pop(context);
        _showSnackBar('Service berhasil diupdate', Colors.green);
      } else {
        _showSnackBar('Gagal mengupdate service', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);
      _showSnackBar('Error: $e', Colors.red);
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
              const SizedBox(height: 16),
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
                      'Edit Service',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLabel('Title'),
              _buildEditableField(controller: _titleController),
              const SizedBox(height: 16),
              _buildLabel('Service Category'),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildLabel('Description'),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              const Text(
                'Pricing & Packages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPackageTabs(),
              const SizedBox(height: 12),
              _buildPricingSection(),
              const SizedBox(height: 24),
              _buildLabel('Service Images'),
              _buildServiceImagesSection(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_saving || _uploadingImage)
                      ? null
                      : _onSavePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
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
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildEditableField({required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFCCAA44)),
        ],
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
      child: _loadingCategories
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Loading categories...'),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedCategoryId,
                hint: const Text('Pilih kategori'),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
            ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _descController,
            maxLines: 6,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 8, right: 24),
            ),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const Positioned(
            top: 6,
            right: 0,
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: Color(0xFFCCAA44),
            ),
          ),
        ],
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
              onTap: () => _changePackageTab(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8C060)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: i < tabs.length - 1
                      ? const Border(
                          right: BorderSide(color: Colors.black26, width: 0.5),
                        )
                      : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Color(0xFFCCAA44),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _deliveryController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Color(0xFFCCAA44),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Short Description',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              TextField(
                controller: _shortDescController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(right: 24),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const Positioned(
                top: 4,
                right: 0,
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Color(0xFFCCAA44),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_serviceImages.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _serviceImages.asMap().entries.map((entry) {
              final imagePath = entry.value;
              final isNetworkImage =
                  imagePath.startsWith('http://') ||
                  imagePath.startsWith('https://');

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isNetworkImage
                        ? Image.network(
                            imagePath,
                            width: 140,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 140,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            width: 140,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 140,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _serviceImages.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _uploadingImage ? null : _pickAndUploadImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFAAAAAA),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: _uploadingImage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '+ Upload Image',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
