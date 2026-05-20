// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/services_controller.dart';
import '../../models/services_model.dart';
import 'service_detail_page.dart';

class _C {
  static const primary     = Color(0xFFFFB74D);
  static const primaryDeep = Color(0xFFFF9800);
  static const bg          = Color(0xFFFFF9F2);
  static const textDark    = Color(0xFF1A1207);
  static const textMid     = Color(0xFF6B5B45);
  static const textSoft    = Color(0xFFAA9880);
  static const chipBg      = Color(0xFFFFE5B4);
  static const shadow      = Color(0x14FF9800);
}

class DetailProfileFreelancer extends StatefulWidget {
  final ServiceModel service;

  const DetailProfileFreelancer({super.key, required this.service});

  @override
  State<DetailProfileFreelancer> createState() => _DetailProfileFreelancerState();
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

    try {
      final results = await Future.wait<dynamic>([
        _supabase
            .from('freelancer_profiles')
            .select('bio, universitas, professional_status, foto_freelancer')
            .eq('id_user', freelancerId)
            .maybeSingle(),
        _supabase
            .from('users')
            .select('foto')
            .eq('id_user', freelancerId)
            .maybeSingle(),
        _supabase
            .from('freelancer_skills')
            .select('skill_name')
            .eq('id_user', freelancerId),
        _supabase
            .from('portfolios')
            .select('judul, deskripsi, thumbnail_url, file_url')
            .eq('id_user', freelancerId)
            .order('created_at', ascending: false),
        _supabase
            .from('service_detail')
            .select()
            .eq('id_freelancer', freelancerId)
            .eq('status', 'active'),
      ]);

      final fp       = results[0] as Map<String, dynamic>?;
      final user     = results[1] as Map<String, dynamic>?;
      final skills   = results[2] as List;
      final portfolios = results[3] as List;
      final servicesData = results[4] as List;

      // Resolusi foto: utamakan foto_freelancer, fallback ke users.foto
      String? photoUrl;
      if (fp?['foto_freelancer'] != null &&
          (fp!['foto_freelancer'] as String).isNotEmpty) {
        photoUrl = fp['foto_freelancer'] as String;
      } else if (user?['foto'] != null &&
          (user!['foto'] as String).isNotEmpty) {
        photoUrl = user['foto'] as String;
      }

      if (mounted) {
        setState(() {
          _photoUrl           = photoUrl;
          _bio                = fp?['bio'] ?? '';
          _university         = fp?['universitas'] ?? widget.service.university;
          _professionalStatus = fp?['professional_status'] ?? '';
          _skills             = skills.map((s) => s['skill_name'] as String).toList();
          _portfolios         = portfolios.map((p) => Map<String, dynamic>.from(p)).toList();
          _services           = servicesData.map((e) => ServiceModel.fromJson(e)).toList();
          _loading            = false;
        });
      }
    } catch (e) {
      debugPrint('loadAllData error: $e');
      if (mounted) setState(() => _loading = false);
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
                                  style: TextStyle(color: _C.textSoft, fontSize: s(13)),
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
                                    separatorBuilder: (_, __) => SizedBox(width: s(14)),
                                    itemBuilder: (ctx, i) => ServiceCard(
                                      service: _services[i],
                                      onTap: () => controller.goToServiceDetail(
                                          context, _services[i]),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Belum ada service aktif.',
                                  style: TextStyle(color: _C.textSoft, fontSize: s(13)),
                                ),

                          SizedBox(height: s(30)),

                          // Portfolio
                          _SectionLabel(text: "Portfolio", s: s),
                          SizedBox(height: s(14)),
                          _portfolios.isNotEmpty
                              ? SizedBox(
                                  height: s(200),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _portfolios.length,
                                    separatorBuilder: (_, __) => SizedBox(width: s(12)),
                                    itemBuilder: (ctx, i) => _PortfolioCard(
                                      portfolio: _portfolios[i],
                                      s: s,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Belum ada portfolio.',
                                  style: TextStyle(color: _C.textSoft, fontSize: s(13)),
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

            // Avatar dari DB
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: _C.shadow, blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: CircleAvatar(
                radius: s(56),
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _photoUrl != null && _photoUrl!.startsWith('http')
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
                  BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: _C.primaryDeep, size: 18),
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

class _PortfolioCard extends StatelessWidget {
  final Map<String, dynamic> portfolio;
  final double Function(double) s;

  const _PortfolioCard({required this.portfolio, required this.s});

  @override
  Widget build(BuildContext context) {
    final thumbUrl = portfolio['thumbnail_url'] as String? ??
        portfolio['file_url'] as String?;

    return Container(
      width: s(160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s(20)),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s(20)),
        child: thumbUrl != null && thumbUrl.startsWith('http')
            ? Image.network(
                thumbUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }
}