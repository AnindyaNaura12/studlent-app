import 'package:flutter/material.dart';
import '../../controllers/portfolio_controller.dart';

class AddPortfolioPage extends StatefulWidget {
  final Map<String, dynamic>? existingPortfolio;
  const AddPortfolioPage({super.key, this.existingPortfolio});

  @override
  State<AddPortfolioPage> createState() => _AddPortfolioPageState();
}

class _AddPortfolioPageState extends State<AddPortfolioPage> {
  final PortfolioController _controller = PortfolioController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String? _selectedCategory;
  String? _imageUrl;
  bool _loading = false;
  bool _uploading = false;

  bool get isEdit => widget.existingPortfolio != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _titleCtrl.text = widget.existingPortfolio!['judul'] ?? '';
      _descCtrl.text = widget.existingPortfolio!['deskripsi'] ?? '';
      _imageUrl = widget.existingPortfolio!['thumbnail_url'];

      final existingCategory = widget.existingPortfolio!['category'];
      _selectedCategory = _controller.categories.contains(existingCategory)
          ? existingCategory
          : null;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _uploading = true);

    final url = await _controller.uploadPortfolioImage();

    if (!mounted) return;
    setState(() {
      _imageUrl = url;
      _uploading = false;
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua field terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    bool success;

    if (isEdit) {
      success = await _controller.updatePortfolio(
        idPortfolio: widget.existingPortfolio!['id_portfolio'],
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory!,
        imageUrl: _imageUrl,
      );
    } else {
      success = await _controller.addPortfolio(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory!,
        imageUrl: _imageUrl,
      );
    }

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan portfolio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      isEdit ? 'Edit Portfolio' : 'Add Portfolio',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _titleCtrl, maxLines: 1),
                      const SizedBox(height: 20),

                      const Text(
                        'Project Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _descCtrl, maxLines: 6),
                      const SizedBox(height: 20),

                      const Text(
                        'Project Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown(),
                      const SizedBox(height: 20),

                      const Text(
                        'Project Image',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _uploading ? null : _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: _uploading
                              ? const Center(child: CircularProgressIndicator())
                              : _imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image_outlined,
                                              size: 40,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to select image',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _loading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB74D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit ? 'Update' : 'Save',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: const Text('Select a category'),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: _controller.categories
              .map<DropdownMenuItem<String>>(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }
}