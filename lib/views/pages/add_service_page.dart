// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../models/services_model.dart';
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
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _shortDescController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDeliveryTime;
  int _selectedPackageTab = 0; // 0=Basic, 1=Standard, 2=Premium

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _shortDescController.dispose();
    super.dispose();
  }

  void _onRequestPressed() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service title wajib diisi')),
      );
      return;
    }

    final newService = ServiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory ?? '',
      description: _descController.text.trim(),
      basicPackage: PackageModel(
        price: _priceController.text.trim(),
        deliveryTime: _selectedDeliveryTime ?? '',
        shortDescription: _shortDescController.text.trim(),
      ),
    );

    widget.controller.addService(newService, widget.onServiceAdded);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── LOGO ──
              Center(
                child: Image.asset(
                  'assets/images/logo_studlent.png',
                  height: 50,
                ),
              ),
              const SizedBox(height: 24),

              // ── TITLE ──
              const Text(
                'Add a new service',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // ── SERVICE TITLE ──
              _buildLabel('Service title'),
              _buildTextField(controller: _titleController, hint: ''),
              const SizedBox(height: 16),

              // ── SERVICE CATEGORY ──
              _buildLabel('Service Category'),
              _buildDropdown(),
              const SizedBox(height: 16),

              // ── SERVICE PREVIEW UPLOAD ──
              _buildLabel('Service  Preview Upload'),
              _buildPreviewUpload(),
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 16),
                child: Text(
                  '*This will be the first thing clients see',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              // ── SERVICE DESCRIPTION ──
              _buildLabel('Service  Description'),
              _buildDescriptionField(),
              const SizedBox(height: 20),

              // ── PRICING & PACKAGES ──
              const Text(
                'Pricing & Packages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildPackageTabs(),
              const SizedBox(height: 12),
              _buildPricingSection(),
              const SizedBox(height: 30),

              // ── CANCEL & REQUEST BUTTONS ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Request
                  GestureDetector(
                    onTap: _onRequestPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Request',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
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
          hintStyle: const TextStyle(color: Colors.black38),
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
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text(
            'Pilih Kategori',
          ), // Tambahkan hint agar tidak error jika null
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          // PERBAIKAN: Gunakan .map<DropdownMenuItem<String>> dan .toList()
          items: widget.controller.categories.map<DropdownMenuItem<String>>((
            String cat,
          ) {
            return DropdownMenuItem<String>(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  Widget _buildPreviewUpload() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Add content',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
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
        decoration: const InputDecoration(
          hintText: 'Explain clearly what the client will get',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
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
            // Price field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Rp',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Delivery time dropdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDeliveryTime,
                    hint: const Text(
                      'Delivery Time',
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                    items: widget.controller.deliveryTimes.map((t) {
                      return DropdownMenuItem<String>(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedDeliveryTime = val),
                  ),
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _shortDescController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Short Description',
              hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.black54,
      currentIndex: 4,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.design_services_outlined),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
