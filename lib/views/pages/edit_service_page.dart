import 'package:flutter/material.dart';
import '../widgets/custom_back_button.dart';
import '../../models/services_model.dart';
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

  String? _selectedCategory;
  int _selectedPackageTab = 0;
  List<String> _serviceImages = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service.title);
    _descController = TextEditingController(text: widget.service.description);
    _priceController = TextEditingController(
      text: widget.service.basicPackage.price,
    );
    _deliveryController = TextEditingController(
      text: widget.service.basicPackage.deliveryTime,
    );
    _shortDescController = TextEditingController(
      text: widget.service.basicPackage.shortDescription,
    );
    _selectedCategory = widget.service.category.isNotEmpty
        ? widget.service.category
        : null;
    _serviceImages = List<String>.from(widget.service.serviceImages);
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

  void _onSavePressed() {
    widget.service.title = _titleController.text.trim();
    widget.service.category = _selectedCategory ?? '';
    widget.service.description = _descController.text.trim();
    widget.service.basicPackage.price = _priceController.text.trim();
    widget.service.basicPackage.deliveryTime = _deliveryController.text.trim();
    widget.service.basicPackage.shortDescription = _shortDescController.text
        .trim();
    widget.service.serviceImages = List<String>.from(_serviceImages);

    widget.controller.updateService(widget.service, widget.onServiceUpdated);
    Navigator.pop(context);
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
              // ── TOP BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back button di kiri
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),

                    // Title di tengah
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
             // ── TITLE FIELD ──
              _buildLabel('Title'),
              _buildEditableField(controller: _titleController),
              const SizedBox(height: 16),

              // ── SERVICE CATEGORY ──
              _buildLabel('Service Category'),
              _buildDropdown(),
              const SizedBox(height: 16),

              // ── DESCRIPTION ──
              _buildLabel('Description'),
              _buildDescriptionField(),
              const SizedBox(height: 20),

              // ── PRICING & PACKAGES ──
              const Text(
                'Pricing & Packages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPackageTabs(),
              const SizedBox(height: 12),
              _buildPricingSection(),
              const SizedBox(height: 24),

              // ── SERVICE IMAGES ──
              _buildLabel('Service Images'),
              _buildServiceImagesSection(),
              const SizedBox(height: 32),

              // ── SAVE BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onSavePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
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

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────

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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text(''),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: widget.controller.categories.map((cat) {
            return DropdownMenuItem<String>(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
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
              onTap: () => setState(() => _selectedPackageTab = i),
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
            // Price
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
            // Delivery time
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
        // Grid gambar
        if (_serviceImages.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _serviceImages.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      entry.value,
                      width: 140,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 140,
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
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

        // Upload button
        GestureDetector(
          onTap: () {
            // TODO: image picker
            // Simulasi tambah gambar
            setState(() {
              _serviceImages.add('assets/images/portfolio_sample.png');
            });
          },
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
            child: const Center(
              child: Text(
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
