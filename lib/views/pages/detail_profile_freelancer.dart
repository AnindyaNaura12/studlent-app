// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // DITAMBAH: untuk buka PDF/file
import '../widgets/custom_back_button.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/services_controller.dart';
import '../../models/services_model.dart';
import 'service_detail_page.dart';

class _C {
  static const primary = Color(0xFFFFB74D);
  static const primaryDeep = Color(0xFFFF9800);
  static const bg = Color(0xFFFFF9F2);
  static const textDark = Color(0xFF1A1207);
  static const textMid = Color(0xFF6B5B45);
  static const textSoft = Color(0xFFAA9880);
  static const chipBg = Color(0xFFFFE5B4);
  static const shadow = Color(0x14FF9800);
}

class DetailProfileFreelancer extends StatefulWidget {
  final ServiceModel service;

  const DetailProfileFreelancer({super.key, required this.service});

  @override
  State<DetailProfileFreelancer> createState() =>
      _DetailProfileFreelancerState();
}

class _DetailProfileFreelancerState extends State<DetailProfileFreelancer> {
  final ServicesController controller = ServicesController();
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  String? _photoUrl;
  String _bio = '';
  String _university = '';
  String _professionalStatus = '';
  List<String> _skills = [];
  List<Map<String, dynamic>> _portfolios = [];
  List<ServiceModel> _services = [];
  List<Map<String, dynamic>> _certificates =
      []; // DITAMBAH: sertifikat freelancer

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final freelancerId = widget.service.freelancerId;
    if (freelancerId == null) {
      setState(() => _loading = false);
      return;
    }

    Map<String, dynamic>? fp;
    Map<String, dynamic>? user;
    List skills = [];
    List portfolios = [];
    List servicesData = [];
    List certsData = [];

    // ── freelancer_profiles ──
    try {
      fp = await _supabase
          .from('freelancer_profiles')
          .select('bio, universitas, professional_status, foto_freelancer')
          .eq('id_user', freelancerId)
          .maybeSingle();
    } catch (e) {
      debugPrint('freelancer_profiles error: $e');
    }

    // ── users ──
    try {
      user = await _supabase
          .from('users')
          .select('foto')
          .eq('id_user', freelancerId)
          .maybeSingle();
    } catch (e) {
      debugPrint('users error: $e');
    }

    // ── freelancer_skills ──
    try {
      skills = await _supabase
          .from('freelancer_skills')
          .select('skill_name')
          .eq('id_user', freelancerId);
    } catch (e) {
      debugPrint('freelancer_skills error: $e');
    }

    // ── portfolios ──
    try {
      portfolios = await _supabase
          .from('portfolios')
          .select(
            'id_portfolio, judul, deskripsi, thumbnail_url, file_url, jobdesk, category',
          )
          .eq('id_user', freelancerId)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('portfolios error: $e');
    }

    // ── service_detail ──
    try {
      servicesData = await _supabase
          .from('service_detail')
          .select()
          .eq('id_freelancer', freelancerId)
          .eq('status', 'active');
    } catch (e) {
      debugPrint('service_detail error: $e');
    }

    // ── freelancer_certificates ──
    try {
      certsData = await _supabase
          .from('freelancer_certificates')
          .select()
          .eq('id_user', freelancerId)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('freelancer_certificates error: $e');
    }

    // ── Foto PP: foto_freelancer → fallback users.foto ──
    String? photoUrl;
    if (fp?['foto_freelancer'] != null &&
        (fp!['foto_freelancer'] as String).isNotEmpty) {
      photoUrl = fp['foto_freelancer'] as String;
    } else if (user?['foto'] != null && (user!['foto'] as String).isNotEmpty) {
      photoUrl = user['foto'] as String;
    }

    if (mounted) {
      setState(() {
        _photoUrl = photoUrl;
        _bio = fp?['bio'] ?? '';
        _university = fp?['universitas'] ?? widget.service.university;
        _professionalStatus = fp?['professional_status'] ?? '';
        _skills = skills.map((s) => s['skill_name'] as String).toList();
        _portfolios = portfolios
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
        _services = servicesData.map((e) => ServiceModel.fromJson(e)).toList();
        _certificates = certsData
            .map((c) => Map<String, dynamic>.from(c))
            .toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(s),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: s(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: s(28)),

                          // About Me
                          _SectionLabel(text: "About Me", s: s),
                          SizedBox(height: s(10)),
                          Text(
                            _bio.isNotEmpty ? _bio : 'Belum ada deskripsi.',
                            style: TextStyle(
                              fontSize: s(14),
                              height: 1.75,
                              color: _C.textMid,
                            ),
                          ),

                          SizedBox(height: s(28)),

                          // Skills
                          _SectionLabel(text: "Skills & Expertise", s: s),
                          SizedBox(height: s(14)),
                          _skills.isNotEmpty
                              ? Wrap(
                                  spacing: s(10),
                                  runSpacing: s(10),
                                  children: _skills
                                      .map((sk) => _SkillChip(label: sk))
                                      .toList(),
                                )
                              : Text(
                                  'Belum ada skill.',
                                  style: TextStyle(
                                    color: _C.textSoft,
                                    fontSize: s(13),
                                  ),
                                ),

                          SizedBox(height: s(30)),

                          // Services Offered
                          _SectionLabel(text: "Services Offered", s: s),
                          SizedBox(height: s(14)),
                          _services.isNotEmpty
                              ? SizedBox(
                                  height: s(320),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _services.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: s(14)),
                                    itemBuilder: (ctx, i) => ServiceCard(
                                      service: _services[i],
                                      onTap: () => controller.goToServiceDetail(
                                        context,
                                        _services[i],
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Belum ada service aktif.',
                                  style: TextStyle(
                                    color: _C.textSoft,
                                    fontSize: s(13),
                                  ),
                                ),

                          SizedBox(height: s(30)),

                          // Portfolio
                          _SectionLabel(text: "Portfolio", s: s),
                          SizedBox(height: s(14)),
                          _portfolios.isNotEmpty
                              ? SizedBox(
                                  height: s(220),
                                  // DIUBAH: height sedikit lebih besar untuk jobdesk label
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _portfolios.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: s(12)),
                                    itemBuilder: (ctx, i) =>
                                        // DIUBAH: _PortfolioCard sekarang bisa di-tap
                                        _PortfolioCard(
                                          portfolio: _portfolios[i],
                                          s: s,
                                          onTap: () => _showPortfolioDetail(
                                            _portfolios[i],
                                            s,
                                          ),
                                        ),
                                  ),
                                )
                              : Text(
                                  'Belum ada portfolio.',
                                  style: TextStyle(
                                    color: _C.textSoft,
                                    fontSize: s(13),
                                  ),
                                ),

                          SizedBox(height: s(30)),

                          // DITAMBAH: Sertifikat section
                          _SectionLabel(text: "Sertifikat", s: s),
                          SizedBox(height: s(14)),
                          _certificates.isNotEmpty
                              ? Wrap(
                                  spacing: s(12),
                                  runSpacing: s(12),
                                  children: _certificates
                                      .map(
                                        (cert) => _CertificateItem(
                                          cert: cert,
                                          s: s,
                                          onTap: () => _showCertificate(cert),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Text(
                                  'Belum ada sertifikat.',
                                  style: TextStyle(
                                    color: _C.textSoft,
                                    fontSize: s(13),
                                  ),
                                ),

                          SizedBox(height: s(40)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // DITAMBAH: tampilkan detail portfolio dalam bottom sheet
  void _showPortfolioDetail(
    Map<String, dynamic> portfolio,
    double Function(double) s,
  ) {
    final thumbUrl =
        portfolio['thumbnail_url'] as String? ??
        portfolio['file_url'] as String?;
    final jobdesk =
        portfolio['jobdesk'] as String? ??
        portfolio['category'] as String? ??
        '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Thumbnail
              if (thumbUrl != null && thumbUrl.startsWith('http'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    thumbUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 48),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Judul
              Text(
                portfolio['judul'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1207),
                ),
              ),
              const SizedBox(height: 8),

              // DITAMBAH: Jobdesk chip
              if (jobdesk.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5B4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFB74D).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    jobdesk,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B5B45),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Deskripsi
              Text(
                portfolio['deskripsi'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF6B5B45),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // DITAMBAH: tampilkan sertifikat
  void _showCertificate(Map<String, dynamic> cert) {
    final fileUrl = cert['file_url'] as String? ?? '';
    final fileName = cert['file_name'] as String? ?? 'Sertifikat';
    final isPdf =
        fileName.toLowerCase().endsWith('.pdf') ||
        fileUrl.toLowerCase().contains('.pdf');

    if (isPdf) {
      // Buka PDF di browser
      final uri = Uri.parse(fileUrl);
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Tampilkan gambar fullscreen
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildHeroHeader(double Function(double) s) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD48A), Color(0xFFFFF0D6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(s(16), s(16), s(16), s(28)),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomBackButton(onTap: () => Navigator.pop(context)),
                ),
                Text(
                  "Freelancer Profile",
                  style: TextStyle(
                    fontSize: s(18),
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
              ],
            ),

            SizedBox(height: s(24)),

            // DIUBAH: Avatar dari foto_freelancer (bukan foto client)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _C.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: s(56),
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    _photoUrl != null && _photoUrl!.startsWith('http')
                    ? NetworkImage(_photoUrl!)
                    : null,
                child: _photoUrl == null
                    ? Icon(Icons.person, size: s(50), color: Colors.grey)
                    : null,
              ),
            ),

            SizedBox(height: s(16)),

            Text(
              widget.service.name,
              style: TextStyle(
                fontSize: s(24),
                fontWeight: FontWeight.w800,
                color: _C.textDark,
              ),
            ),

            SizedBox(height: s(4)),

            Text(
              _professionalStatus.isNotEmpty
                  ? _professionalStatus
                  : widget.service.title,
              style: TextStyle(
                fontSize: s(14),
                color: _C.textMid,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (_university.isNotEmpty) ...[
              SizedBox(height: s(4)),
              Text(
                _university,
                style: TextStyle(fontSize: s(12), color: _C.textSoft),
              ),
            ],

            SizedBox(height: s(14)),

            Container(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: _C.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: _C.primaryDeep,
                    size: 18,
                  ),
                  SizedBox(width: s(6)),
                  Text(
                    "${widget.service.rating}",
                    style: TextStyle(
                      fontSize: s(15),
                      fontWeight: FontWeight.w800,
                      color: _C.textDark,
                    ),
                  ),
                  SizedBox(width: s(4)),
                  Text(
                    "(${widget.service.totalReviews} reviews)",
                    style: TextStyle(fontSize: s(13), color: _C.textSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final double Function(double) s;

  const _SectionLabel({required this.text, required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: s(20),
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: s(10)),
        Text(
          text,
          style: TextStyle(
            fontSize: s(18),
            fontWeight: FontWeight.w800,
            color: _C.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Skill Chip ───────────────────────────────────────────────
class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: _C.chipBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _C.primary.withOpacity(0.4), width: 1.2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: _C.textDark,
        ),
      ),
    );
  }
}

// ─── Portfolio Card ───────────────────────────────────────────
// DIUBAH: tambah onTap dan tampilkan jobdesk label
class _PortfolioCard extends StatelessWidget {
  final Map<String, dynamic> portfolio;
  final double Function(double) s;
  final VoidCallback onTap; // DITAMBAH

  const _PortfolioCard({
    required this.portfolio,
    required this.s,
    required this.onTap, // DITAMBAH
  });

  @override
  Widget build(BuildContext context) {
    final thumbUrl =
        portfolio['thumbnail_url'] as String? ??
        portfolio['file_url'] as String?;
    // DITAMBAH: ambil jobdesk, fallback ke category untuk data lama
    final jobdesk =
        portfolio['jobdesk'] as String? ??
        portfolio['category'] as String? ??
        '';

    return GestureDetector(
      onTap: onTap, // DITAMBAH
      child: Container(
        width: s(160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(s(20)),
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(s(20)),
                topRight: Radius.circular(s(20)),
                // DIUBAH: kalau ada jobdesk, bawah tidak rounded
                bottomLeft: jobdesk.isEmpty
                    ? Radius.circular(s(20))
                    : Radius.zero,
                bottomRight: jobdesk.isEmpty
                    ? Radius.circular(s(20))
                    : Radius.zero,
              ),
              child: thumbUrl != null && thumbUrl.startsWith('http')
                  ? Image.network(
                      thumbUrl,
                      width: s(160),
                      height: s(160),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(s),
                    )
                  : _placeholder(s),
            ),

            // DITAMBAH: jobdesk label di bawah gambar
            if (jobdesk.isNotEmpty)
              Container(
                width: s(160),
                padding: EdgeInsets.symmetric(
                  horizontal: s(10),
                  vertical: s(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(s(20)),
                    bottomRight: Radius.circular(s(20)),
                  ),
                ),
                child: Text(
                  jobdesk,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: s(11),
                    fontWeight: FontWeight.w600,
                    color: _C.textMid,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double Function(double) s) {
    return Container(
      width: s(160),
      height: s(160),
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }
}

// ─── Certificate Item ─────────────────────────────────────────
// DITAMBAH: widget sertifikat di detail profile freelancer
class _CertificateItem extends StatelessWidget {
  final Map<String, dynamic> cert;
  final double Function(double) s;
  final VoidCallback onTap;

  const _CertificateItem({
    required this.cert,
    required this.s,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fileUrl = cert['file_url'] as String? ?? '';
    final fileName = cert['file_name'] as String? ?? 'Sertifikat';
    final isPdf =
        fileName.toLowerCase().endsWith('.pdf') ||
        fileUrl.toLowerCase().contains('.pdf');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: s(120),
        padding: EdgeInsets.all(s(10)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0D6),
          borderRadius: BorderRadius.circular(s(12)),
          border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.4)),
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview thumbnail atau PDF icon
            ClipRRect(
              borderRadius: BorderRadius.circular(s(8)),
              child: isPdf
                  ? Container(
                      width: s(80),
                      height: s(80),
                      color: Colors.red.shade50,
                      child: const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    )
                  : Image.network(
                      fileUrl,
                      width: s(80),
                      height: s(80),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: s(80),
                        height: s(80),
                        color: Colors.orange.shade50,
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.orange,
                          size: 36,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: s(6)),
            Text(
              fileName,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: s(11), color: _C.textMid),
            ),
            SizedBox(height: s(4)),
            Text(
              isPdf ? 'Tap untuk buka' : 'Tap untuk lihat',
              style: TextStyle(fontSize: s(10), color: _C.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
