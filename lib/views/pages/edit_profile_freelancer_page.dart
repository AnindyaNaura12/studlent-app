// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../models/freelancer_profile_model.dart';

class EditProfileFreelancerPage extends StatefulWidget {
  final FreelancerProfileModel? initialModel;

  const EditProfileFreelancerPage({super.key, this.initialModel});

  @override
  State<EditProfileFreelancerPage> createState() =>
      _EditProfileFreelancerPageState();
}

class _EditProfileFreelancerPageState extends State<EditProfileFreelancerPage> {
  late EditProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(initialModel: widget.initialModel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    final error = _controller.validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final saved = _controller.save();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan!')));
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── TOP BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Image.asset('assets/images/logo_studlent.png', height: 40),
                  ],
                ),
              ),

              // ── SCROLLABLE CONTENT ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ── TITLE ──
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Let clients know who you are',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── AVATAR ──
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFB74D),
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.orange.withOpacity(0.2),
                                backgroundImage: AssetImage(
                                  _controller.model.avatarPath,
                                ),
                                onBackgroundImageError: (_, __) {},
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                // TODO: image picker
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EAE0),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── NAME ──
                      _buildSectionLabel('Name'),
                      _buildEditableField(
                        controller: _controller.nameController,
                        hint: 'Carla Park',
                      ),
                      const SizedBox(height: 20),

                      // ── PROFESSIONAL STATUS ──
                      _buildSectionLabel('Professional Status'),
                      _buildEditableField(
                        controller: _controller.professionalStatusController,
                        hint: 'UI/UX Design',
                      ),
                      const SizedBox(height: 20),

                      // ── ABOUT ME ──
                      _buildSectionLabel('About Me'),
                      _buildAboutMeField(),
                      const SizedBox(height: 24),

                      // ── MY SKILLS ──
                      _buildSectionLabel('My Skills'),
                      _buildSkillsSection(),
                      const SizedBox(height: 24),

                      // ── PORTFOLIO ──
                      _buildSectionLabel('Portofolio'),
                      _buildPortfolioSection(),
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
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // EDITABLE FIELD (single line)
  // ─────────────────────────────────────────────
  Widget _buildEditableField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8D5B7), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black45),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFCCAA66)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ABOUT ME (multiline)
  // ─────────────────────────────────────────────
  Widget _buildAboutMeField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D5B7), width: 1),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _controller.aboutMeController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Tell clients about yourself...',
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 10, right: 24),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const Positioned(
            top: 8,
            right: 0,
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: Color(0xFFCCAA66),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SKILLS SECTION
  // ─────────────────────────────────────────────
  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D5B7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skill chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _controller.skills.map((skill) {
              return _buildSkillChip(skill);
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Add Skill label
          const Row(
            children: [
              Text('📚', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Add Skill',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Input + button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFE0D0B8),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller.skillInputController,
                    decoration: const InputDecoration(
                      hintText: 'Type a skill...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onSubmitted: (val) =>
                        _controller.addSkill(val, () => setState(() {})),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _controller.addSkill(
                  _controller.skillInputController.text,
                  () => setState(() {}),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFCCAA66),
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    '+ Add',
                    style: TextStyle(
                      color: Color(0xFFCCAA66),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    // Warna chip bergantian seperti di gambar (biru muda & krem)
    final isBlue = _controller.skills.indexOf(skill) % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isBlue ? const Color(0xFFB8CCF0) : const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _controller.removeSkill(skill, () => setState(() {})),
            child: const Icon(Icons.close, size: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PORTFOLIO SECTION
  // ─────────────────────────────────────────────
  Widget _buildPortfolioSection() {
    return Column(
      children: [
        // Grid foto portfolio
        if (_controller.portfolioImages.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: _controller.portfolioImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _controller.portfolioImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _controller.removePortfolioImage(
                        index,
                        () => setState(() {}),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
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
            },
          ),
          const SizedBox(height: 12),
        ],

        // Placeholder portfolio (gambar contoh dari gambar desain)
        if (_controller.portfolioImages.isEmpty)
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8D5B7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _portfolioPlaceholderCard(isHighlighted: true),
                const SizedBox(width: 8),
                _portfolioPlaceholderCard(),
                const SizedBox(width: 8),
                _portfolioPlaceholderCard(),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // + Add Portfolio button
        GestureDetector(
          onTap: () {
            // TODO: image picker untuk portfolio
            // Simulasi tambah placeholder
            _controller.addPortfolioImage(
              'assets/images/portfolio_sample.png',
              () => setState(() {}),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8D5B7)),
            ),
            child: const Center(
              child: Text(
                '+ Add Portofolio',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCCAA66),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _portfolioPlaceholderCard({bool isHighlighted = false}) {
    return Container(
      width: 80,
      height: 130,
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF4B5BF5) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isHighlighted
          ? const Center(
              child: Icon(Icons.phone_android, color: Colors.white, size: 30),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 8,
                  width: 60,
                  margin: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: 50,
                  margin: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
    );
  }
}
