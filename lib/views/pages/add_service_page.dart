// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/custom_back_button.dart';
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

  String get _currentPackageKey =>
      _selectedPackageTab == 0
          ? 'basic'
          : _selectedPackageTab == 1
          ? 'standard'
          : 'premium';

  Future<void> _onRequestPressed() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service title wajib diisi'),
        ),
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

      final categoryResult = await supabase
          .from('service_categories')
          .select('id_category')
          .eq('nama', _selectedCategory ?? '');

      final idCategory = categoryResult.isNotEmpty
          ? categoryResult[0]['id_category']
          : null;

      final serviceResult = await supabase
          .from('services')
          .insert({
            'id_freelancer': user['id_user'],
            'id_category': idCategory,
            'judul': _titleController.text.trim(),
            'deskripsi': _descController.text.trim(),
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final idService = serviceResult['id_service'];

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
        });
      }

      setState(() => _loading = false);

      widget.onServiceAdded();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service berhasil diajukan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

              _buildLabel('Service title'),
              _buildTextField(
                controller: _titleController,
                hint: 'Masukkan judul service',
              ),

              const SizedBox(height: 16),

              _buildLabel('Service Category'),
              _buildDropdown(),

              const SizedBox(height: 16),

              _buildLabel('Service Description'),
              _buildDescriptionField(),

              const SizedBox(height: 24),

              const Text(
                'Pricing & Packages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildPackageTabs(),

              const SizedBox(height: 16),

              _buildPricingSection(),

              const SizedBox(height: 32),

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
                        color: const Color(0xFFFFB74D),
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
          fontWeight: FontWeight.bold,
          fontSize: 15,
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
          hint: const Text('Pilih kategori'),
          items: widget.controller.categories
              .map<DropdownMenuItem<String>>(
                (String cat) => DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
            });
          },
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
        decoration: const InputDecoration(
          hintText: 'Jelaskan service kamu',
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
              onTap: () {
                setState(() {
                  _selectedPackageTab = i;
                });
              },
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
                      color: isSelected
                          ? Colors.black
                          : Colors.black54,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Package: ${_currentPackageKey.toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _buildPriceField(ctrlMap['price']!),

        const SizedBox(height: 12),

        _buildDeliveryField(ctrlMap['delivery']!),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: ctrlMap['desc']!,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Short Description',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Rp 50.000',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDeliveryField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Delivery time (hari)',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}