// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/custom_back_button.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/portfolio_controller.dart';
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
  final PortfolioController _portfolioController = PortfolioController();
  final supabase = Supabase.instance.client;

  String? _fotoUrl;
  bool _loadingData = true;
  bool _uploadingCert = false;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(initialModel: widget.initialModel);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loadingData = true);

    final profileCtrl = ProfileController();
    final data = await profileCtrl.getCurrentUser();

    if (data != null && mounted) {
      setState(() => _fotoUrl = data['foto_freelancer']);
    }

    await _controller.loadFromSupabase();

    if (mounted) {
      setState(() => _loadingData = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    final error = _controller.validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _controller.saveToSupabase();

    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addCertificate() async {
    setState(() => _uploadingCert = true);

    try {
      final result = await _portfolioController.uploadCertificate();
      if (result == null) {
        if (mounted) setState(() => _uploadingCert = false);
        return;
      }

      final authUser = supabase.auth.currentUser;
      if (authUser == null || authUser.email == null) {
        if (mounted) setState(() => _uploadingCert = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User belum login'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userData = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .maybeSingle();

      if (userData == null) {
        if (mounted) setState(() => _uploadingCert = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data user tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final idUser = userData['id_user'];

      final saved = await _portfolioController.addCertificate(
        fileUrl: result['url']!,
        fileName: result['name']!,
        idUser: idUser,
      );

      if (!mounted) return;

      if (saved) {
        _controller.addCertificateData({
          'file_url': result['url']!,
          'file_name': result['name']!,
        }, () {});

        setState(() => _uploadingCert = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sertifikat berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _uploadingCert = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan sertifikat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _uploadingCert = false);
      debugPrint('AddCertificate error: $e');
    }
  }

  Future<void> _deleteCertificate(int index) async {
    final cert = _controller.certificateData[index];
    final idCert = cert['id_certificate'] as int?;

    if (idCert != null) {
      final authUser = supabase.auth.currentUser;
      if (authUser == null || authUser.email == null) return;

      final userData = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .maybeSingle();

      if (userData == null) return;
      final idUser = userData['id_user'];

      await _portfolioController.deleteCertificate(idCert, idUser: idUser);
    }

    _controller.removeCertificateData(index, () {
      if (mounted) setState(() {});
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sertifikat dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomBackButton(
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loadingData
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final profileCtrl = ProfileController();
                                    final data = await profileCtrl
                                        .getCurrentUser();
                                    if (data == null) return;

                                    final url = await profileCtrl
                                        .uploadProfileImage(
                                          data['id_user'],
                                          isFreelancer: true,
                                        );

                                    if (url != null && mounted) {
                                      setState(() => _fotoUrl = url);
                                    }
                                  },
                                  child: Stack(
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
                                          backgroundColor: Colors.orange
                                              .withOpacity(0.2),
                                          child: ClipOval(
                                            child: _fotoUrl != null
                                                ? Image.network(
                                                    _fotoUrl!,
                                                    width: 104,
                                                    height: 104,
                                                    fit: BoxFit.cover,
                                                    key: ValueKey(_fotoUrl),
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Image.asset(
                                                          'assets/images/icons/profile.png',
                                                          width: 104,
                                                          height: 104,
                                                          fit: BoxFit.cover,
                                                        ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/icons/profile.png',
                                                    width: 104,
                                                    height: 104,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFB74D),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap untuk ganti foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildSectionLabel('Name'),
                          _buildEditableField(
                            controller: _controller.nameController,
                            hint: 'Nama kamu',
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Professional Status'),
                          _buildEditableField(
                            controller:
                                _controller.professionalStatusController,
                            hint: 'Contoh: UI/UX Designer',
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel('About Me'),
                          _buildAboutMeField(),
                          const SizedBox(height: 24),
                          _buildSectionLabel('My Skills'),
                          _buildSkillsSection(),
                          const SizedBox(height: 24),
                          _buildSectionLabel('Sertifikat & Penghargaan'),
                          _buildCertificateSection(),
                          const SizedBox(height: 32),
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
    );
  }

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
          if (_controller.skills.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _controller.skills
                  .map((skill) => _buildSkillChip(skill))
                  .toList(),
            ),
            const SizedBox(height: 14),
          ],
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

  Widget _buildCertificateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambahkan sertifikat, piagam, atau penghargaan\nuntuk meyakinkan klien',
          style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 12),
        if (_controller.certificateData.isNotEmpty)
          Column(
            children: _controller.certificateData
                .asMap()
                .entries
                .map((entry) => _buildCertificateItem(entry.key, entry.value))
                .toList(),
          ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _uploadingCert ? null : _addCertificate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8D5B7)),
            ),
            child: Center(
              child: _uploadingCert
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFCCAA66),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '+ Tambah Sertifikat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCCAA66),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateItem(int index, Map<String, dynamic> cert) {
    final fileUrl = cert['file_url'] as String? ?? '';
    final fileName = cert['file_name'] as String? ?? 'Sertifikat';
    final isPdf =
        fileName.toLowerCase().endsWith('.pdf') ||
        fileUrl.toLowerCase().contains('.pdf');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D5B7)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (fileUrl.isEmpty) return;
              final uri = Uri.parse(fileUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isPdf
                  ? Container(
                      width: 56,
                      height: 56,
                      color: Colors.red.shade50,
                      child: const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    )
                  : Image.network(
                      fileUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.orange.shade50,
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap untuk lihat',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteCertDialog(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCertDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Sertifikat?'),
        content: const Text('Sertifikat ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCertificate(index);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
