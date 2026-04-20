import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../widgets/feature_item.dart';
import '../widgets/category_card.dart';
import '../widgets/freelancer_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final HomeController _controller = HomeController();

  @override
  Widget build(BuildContext context) {
    final categories = _controller.getCategories();
    final freelancers = _controller.getPopularFreelancers();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ══════════════════════
              // HEADER
              // ══════════════════════
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_studlent.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search services...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ══════════════════════
              // HERO TEXT
              // ══════════════════════
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: "Turn Student Talent\nInto Your "),
                    TextSpan(
                      text: "Best Solution",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: "."),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Text(
                  textAlign: TextAlign.center,
                  "Connect with skilled students ready to deliver quality work, fast and affordable",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ══════════════════════
              // HERO IMAGE
              // ══════════════════════
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/hero_student.png',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ══════════════════════
              // WHY CHOOSE
              // ══════════════════════
              const Center(
                child: Text(
                  "Why Choose Student Talent?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeatureItem(
                    iconPath: "assets/images/icons/faster_delivery.png",
                    label: "Faster\nDelivery",
                  ),
                  FeatureItem(
                    iconPath: "assets/images/icons/student_pricing.png",
                    label: "Student\nPricing",
                  ),
                  FeatureItem(
                    iconPath: "assets/images/icons/verified_portofolios.png",
                    label: "Verified Student\nPortfolios",
                  ),
                  FeatureItem(
                    iconPath: "assets/images/icons/secure_payments.png",
                    label: "Secure\nPayments",
                  ),
                ],
              ),

              // ══════════════════════
              // SERVICE CATEGORIES
              // ══════════════════════
              const SizedBox(height: 25),
              const Center(
                child: Text(
                  "Service Categories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.1,
                children: categories
                    .map((cat) => CategoryCard(category: cat))
                    .toList(),
              ),

              // ══════════════════════
              // MOST POPULAR FREELANCER
              // ══════════════════════
              const SizedBox(height: 32),
              const Text(
                "Most Popular Freelancer in Writing Translation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: freelancers
                      .map((f) => FreelancerCard(freelancer: f))
                      .toList(),
                ),
              ),

              // ══════════════════════
              // CTA — Make It All Happen
              // ══════════════════════
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Make It All Happen",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Hire talented students or start selling your skills today.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE0B2),
                        foregroundColor: Colors.orange.shade900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Join Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════
              // STUDLENT PROMO BANNER
              // ══════════════════════
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF8B6914),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/banner_studlent_bg.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x66704A10),
                                Color(0x226B500A),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 0, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 20, right: 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/logo_studlent.png',
                                      height: 32,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.school,
                                              color: Colors.white, size: 32),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Yuk, Gunakan Jasa\nMahasiswa Sekarang!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Temukan talenta muda yang kreatif, kompeten, dan siap membantu proyekmu berkembang.",
                                      style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.90),
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              height: 150,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: _personPhoto(
                                      'assets/images/freelancers/promo_person_1.png',
                                      width: 55,
                                      height: 110,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: _personPhoto(
                                      'assets/images/freelancers/promo_person_3.png',
                                      width: 55,
                                      height: 110,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: _centerPhoto(
                                      'assets/images/freelancers/promo_person_2.png',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _personPhoto(String path,
      {required double height, required double width}) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: SizedBox(
        height: height,
        width: width,
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white24,
            child:
                const Icon(Icons.person, color: Colors.white54, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _centerPhoto(String path) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _personPhoto(path, width: 65, height: 140),
    );
  }
}
