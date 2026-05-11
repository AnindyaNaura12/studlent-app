import 'package:flutter/material.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_text_field.dart';
import '../../controllers/freelancer_registration_controller.dart';

class RegisterFreelancerPage extends StatefulWidget {
  const RegisterFreelancerPage({super.key});

  @override
  State<RegisterFreelancerPage> createState() =>
      _RegisterFreelancerPageState();
}

class _RegisterFreelancerPageState extends State<RegisterFreelancerPage> {
  final RegistrationController _controller = RegistrationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Form(
              key: _controller.formKeyStep1,
              child: Column(
                children: [
                  // ── Top Bar ──
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Daftar Freelancer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Step 1 dari 2',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Form Card ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Info Pribadi ──
                        _sectionTitle('Informasi Pribadi'),

                        CustomTextField(
                          label: 'Nama Lengkap',
                          hint: 'Masukkan nama lengkap',
                          onSaved: (v) =>
                              _controller.model.fullName = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),

                        CustomTextField(
                          label: 'Status Profesional',
                          hint: 'Contoh: UI/UX Designer, Web Developer',
                          onSaved: (v) =>
                              _controller.model.professionalStatus = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Status profesional tidak boleh kosong'
                              : null,
                        ),

                        CustomTextField(
                          label: 'Universitas',
                          hint: 'Contoh: Universitas Brawijaya',
                          onSaved: (v) =>
                              _controller.model.university = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Universitas tidak boleh kosong'
                              : null,
                        ),

                        CustomTextField(
                          label: 'Jurusan',
                          hint: 'Contoh: Teknik Informatika',
                          onSaved: (v) =>
                              _controller.model.major = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Jurusan tidak boleh kosong'
                              : null,
                        ),

                        CustomTextField(
                          label: 'Nomor HP',
                          hint: '+6281234567890',
                          keyboardType: TextInputType.phone,
                          onSaved: (v) =>
                              _controller.model.phoneNumber = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Nomor HP tidak boleh kosong'
                              : null,
                        ),

                        // ── Info Pembayaran ──
                        _sectionTitle('Informasi Pembayaran'),

                        const SizedBox(height: 8),

                        // Bank dropdown
                        const Text(
                          'Bank',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _controller.selectedBank,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          hint: const Text('Pilih bank'),
                          items: _controller.bankList
                              .map((bank) => DropdownMenuItem(
                                    value: bank,
                                    child: Text(bank),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() {
                            _controller.selectedBank = val;
                            _controller.model.bankName = val;
                          }),
                          validator: (v) =>
                              v == null ? 'Pilih bank terlebih dahulu' : null,
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Nomor Rekening',
                          hint: 'Masukkan nomor rekening',
                          keyboardType: TextInputType.number,
                          onSaved: (v) =>
                              _controller.model.accountNumber = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Nomor rekening tidak boleh kosong'
                              : null,
                        ),

                        CustomTextField(
                          label: 'Nama Pemilik Rekening',
                          hint: 'Sesuai buku tabungan',
                          onSaved: (v) =>
                              _controller.model.accountHolder = v ?? '',
                          validator: (v) => v!.trim().isEmpty
                              ? 'Nama pemilik rekening tidak boleh kosong'
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // ── Next Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () =>
                                _controller.handleNextStep(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Lanjut →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3B82F6),
        ),
      ),
    );
  }
}