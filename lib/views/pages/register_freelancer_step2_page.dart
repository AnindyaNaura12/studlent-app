import 'package:flutter/material.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/agreement_widget.dart';
import '../pages/terms_conditions_page.dart';
import '../pages/freelancer_agreement_page.dart';
import '../../controllers/freelancer_registration_controller.dart';
import '../../models/skill_model.dart';

class RegisterFreelancerStep2Page extends StatefulWidget {
  final RegistrationController controller;

  const RegisterFreelancerStep2Page({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterFreelancerStep2Page> createState() =>
      _RegisterFreelancerStep2PageState();
}

class _RegisterFreelancerStep2PageState
    extends State<RegisterFreelancerStep2Page> {
  final TextEditingController _skillCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _skillCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillCtrl.text.trim().isEmpty) return;
    widget.controller.addSkill(_skillCtrl.text);
    setState(() {});
    _skillCtrl.clear();
  }

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
                          'Step 2 dari 2',
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
                  child: Form(
                    key: widget.controller.formKeyStep2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Skills ──
                        const Text(
                          'Skills kamu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tambahkan skill yang kamu kuasai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Input skill
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _skillCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: Figma, Flutter, ...',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _addSkill(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _addSkill,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '+ Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Skill chips
                        if (widget.controller.model.selectedSkills.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.controller.model.selectedSkills
                                .map((skill) => _buildChip(skill))
                                .toList(),
                          ),

                        const SizedBox(height: 20),

                        // ── Bio ──
                        CustomTextField(
                          label: 'Bio Singkat',
                          hint: 'Ceritakan sedikit tentang dirimu...',
                          maxLines: 3,
                          maxLength: 200,
                          onSaved: (v) =>
                              widget.controller.model.bio = v ?? '',
                        ),

                        const SizedBox(height: 16),

                        // ── Agreement ──
                        AgreementWidget(
                          value: widget.controller.model.agreeToTerms,
                          text: "Terms & Conditions",
                          onTap: (v) => setState(() {
                            widget.controller.model.agreeToTerms = v;
                          }),
                          onLinkTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsConditionsPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        AgreementWidget(
                          value: widget.controller.model.agreeToAgreement,
                          text: "Freelancer Agreement",
                          onTap: (v) => setState(() {
                            widget.controller.model.agreeToAgreement = v;
                          }),
                          onLinkTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const FreelancerAgreementPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // ── Finish Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    setState(() => _loading = true);
                                    await widget.controller
                                        .handleFinish(context);
                                    if (mounted) {
                                      setState(() => _loading = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Daftar Sekarang 🎉',
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
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(Skill skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              widget.controller.removeSkill(skill.name);
              setState(() {});
            },
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }
}