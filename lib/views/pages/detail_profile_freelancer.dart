import 'package:flutter/material.dart';
import '../../models/services_model.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/services_controller.dart';
import 'service_detail_page.dart';
 
// ─── Design Tokens ────────────────────────────────────────────────────────────
class _C {
  static const primary     = Color(0xFFFFB74D);
  static const primaryDim  = Color(0xFFFFE0A3);
  static const primaryDeep = Color(0xFFFF9800);
  static const bg          = Color(0xFFFFF9F2);
  static const surface     = Color(0xFFFFFFFF);
  static const surfaceWarm = Color(0xFFF7EFE5);
  static const textDark    = Color(0xFF1A1207);
  static const textMid     = Color(0xFF6B5B45);
  static const textSoft    = Color(0xFFAA9880);
  static const chipBg      = Color(0xFFFFE5B4);
  static const shadow      = Color(0x14FF9800);
}
 
class DetailProfileFreelancer extends StatelessWidget {
  final ServiceModel service;
 
  final MyServicesController controller = MyServicesController();
 
  DetailProfileFreelancer({
    super.key,
    required this.service,
  });
 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);
 
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
 
              // ── HERO HEADER ─────────────────────────────────────────────
              _HeroHeader(service: service, s: s),
 
              // ── BODY CONTENT ────────────────────────────────────────────
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
                      service.description,
                      style: TextStyle(
                        fontSize: s(14),
                        height: 1.75,
                        color: _C.textMid,
                        letterSpacing: 0.1,
                      ),
                    ),
 
                    SizedBox(height: s(28)),
 
                    // Skills
                    _SectionLabel(text: "Skills & Expertise", s: s),
                    SizedBox(height: s(14)),
                    Wrap(
                      spacing: s(10),
                      runSpacing: s(10),
                      children: const [
                        _SkillChip(label: "Programming"),
                        _SkillChip(label: "Design"),
                        _SkillChip(label: "UI/UX"),
                      ],
                    ),
 
                    SizedBox(height: s(30)),
 
                    // Services Offered
                    _SectionLabel(text: "Services Offered", s: s),
                    SizedBox(height: s(14)),
                    SizedBox(
                      height: s(320),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ServiceCard(
                            service: service,
                            onTap: () =>
                                controller.goToServiceDetail(context, service),
                          ),
                          SizedBox(width: s(14)),
                          ServiceCard(
                            service: service,
                            onTap: () =>
                                controller.goToServiceDetail(context, service),
                          ),
                          SizedBox(width: s(14)),
                        ],
                      ),
                    ),
 
                    SizedBox(height: s(30)),
 
                    // Portfolio
                    _SectionLabel(text: "Portfolio", s: s),
                    SizedBox(height: s(14)),
                    SizedBox(
                      height: s(200),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _PortfolioCard(imagePath: service.imagePath, s: s),
                          SizedBox(width: s(12)),
                          _PortfolioCard(imagePath: service.imagePath, s: s),
                          SizedBox(width: s(12)),
                          _PortfolioCard(imagePath: service.imagePath, s: s),
                          SizedBox(width: s(12)),
                        ],
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
}
 
// ─── Hero Header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final ServiceModel service;
  final double Function(double) s;
 
  const _HeroHeader({required this.service, required this.s});
 
  @override
  Widget build(BuildContext context) {
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
            // Top bar
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomBackButton(
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  "Freelancer Profile",
                  style: TextStyle(
                    fontSize: s(18),
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
 
            SizedBox(height: s(24)),
 
            // Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _C.shadow,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: s(56),
                backgroundImage: AssetImage(
                  service.imagePath ?? 'assets/images/placeholder.png',
                ),
              ),
            ),
 
            SizedBox(height: s(16)),
 
            // Name
            Text(
              service.name,
              style: TextStyle(
                fontSize: s(24),
                fontWeight: FontWeight.w800,
                color: _C.textDark,
                letterSpacing: -0.5,
              ),
            ),
 
            SizedBox(height: s(4)),
 
            // Title
            Text(
              service.title,
              style: TextStyle(
                fontSize: s(14),
                color: _C.textMid,
                fontWeight: FontWeight.w500,
              ),
            ),
 
            SizedBox(height: s(14)),
 
            // Rating pill
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: s(16),
                vertical: s(8),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _C.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: _C.primaryDeep, size: 18),
                  SizedBox(width: s(6)),
                  Text(
                    "${service.rating}",
                    style: TextStyle(
                      fontSize: s(15),
                      fontWeight: FontWeight.w800,
                      color: _C.textDark,
                    ),
                  ),
                  SizedBox(width: s(4)),
                  Text(
                    "(${service.totalReviews} reviews)",
                    style: TextStyle(
                      fontSize: s(13),
                      color: _C.textSoft,
                      fontWeight: FontWeight.w500,
                    ),
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
 
// ─── Section Label ────────────────────────────────────────────────────────────
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
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
 
// ─── Skill Chip ───────────────────────────────────────────────────────────────
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
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
 
// ─── Portfolio Card ───────────────────────────────────────────────────────────
class _PortfolioCard extends StatelessWidget {
  final String? imagePath;
  final double Function(double) s;
 
  const _PortfolioCard({required this.imagePath, required this.s});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: s(160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s(20)),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s(20)),
        child: Image.asset(
          imagePath ?? 'assets/images/placeholder.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}