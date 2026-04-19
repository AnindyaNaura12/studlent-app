import 'package:flutter/material.dart';
import '../widgets/feature_item.dart';
import '../widgets/category_card.dart';
import '../widgets/freelancer_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                          boxShadow: [
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
                const Text(
                  "Turn Student Talent Into Your Best Solution.",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Connect with skilled students ready to deliver quality work, fast and affordable",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // ══════════════════════
                // HERO IMAGE
                // ══════════════════════
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/hero_student.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
                  children: const [
                    CategoryCard(
                        title: "Website\nDevelopment",
                        iconPath:
                            "assets/images/categories/website_development.png"),
                    CategoryCard(
                        title: "Graphic Design",
                        iconPath:
                            "assets/images/categories/graphic_design.png"),
                    CategoryCard(
                        title: "Photography",
                        iconPath:
                            "assets/images/categories/photography.png"),
                    CategoryCard(
                        title: "Video Editing",
                        iconPath:
                            "assets/images/categories/video_editing.png"),
                    CategoryCard(
                        title: "Image Editing",
                        iconPath:
                            "assets/images/categories/image_editing.png"),
                    CategoryCard(
                        title: "Writing &\nTranslation",
                        iconPath:
                            "assets/images/categories/writing_translation.png"),
                  ],
                ),

                // ══════════════════════
                // MOST POPULAR FREELANCER
                // ══════════════════════
                const SizedBox(height: 32),
                const Text(
                  "Most Popular Freelancer\nin Writing Translation",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontal scroll freelancer cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      FreelancerCard(
                        name: "Carla",
                        rating: 4.9,
                        reviewCount: 200,
                        experience: "3 years of experience.",
                        skills: "Java, CSS",
                        university: "Universitas Brawijaya",
                        price: "Rp. 200.000",
                        imagePath:
                            "assets/images/freelancers/freelancer_1.png",
                      ),
                      FreelancerCard(
                        name: "Carla",
                        rating: 4.9,
                        reviewCount: 200,
                        experience: "3 years of experience",
                        skills: "Java, CSS",
                        university: "Politeknik Negeri Malang",
                        price: "Rp. 250.000",
                        imagePath:
                            "assets/images/freelancers/freelancer_2.png",
                      ),
                      FreelancerCard(
                        name: "Reza",
                        rating: 4.8,
                        reviewCount: 150,
                        experience: "2 years of experience",
                        skills: "Python, UI/UX",
                        university: "Universitas Negeri Malang",
                        price: "Rp. 175.000",
                        imagePath:
                            "assets/images/freelancers/freelancer_3.png",
                      ),
                    ],
                  ),
                ),

                // ══════════════════════
                // CTA — Make It All Happen
                // ══════════════════════
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          "Make It All Happen With Freelancer",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "JOIN NOW",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
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

                        // Layer 1: background image kampus
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/banner_studlent_bg.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),

                        // Layer 2: overlay tipis — bg kampus tetap terlihat jelas
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x66704A10), // kiri: opacity ~40%
                                  Color(0x226B500A), // kanan: opacity ~13%
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),

                        // Layer 3: konten
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(18, 20, 0, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [

                              // Teks kiri
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Logo image saja — tanpa text "Studlent"
                                      Image.asset(
                                        'assets/images/logo_studlent.png',
                                        height: 32,
                                        fit: BoxFit.contain,
                                        // Tidak pakai color tinting → warna asli logo (biru) tetap tampil
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.school,
                                                color: Colors.white,
                                                size: 32),
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
                                          color: Colors.white
                                              .withOpacity(0.90),
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 3 foto portrait — rata bawah, foto 1 & 3 identik, foto 2 tengah lebih tinggi
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _personPhoto(
                                      'assets/images/freelancers/promo_person_1.png',
                                      width: 45,
                                      height: 105,
                                    ),
                                    const SizedBox(width: 5),
                                    _personPhoto(
                                      'assets/images/freelancers/promo_person_2.png',
                                      width: 45,
                                      height: 130,
                                    ),
                                    const SizedBox(width: 5),
                                    _personPhoto(
                                      'assets/images/freelancers/promo_person_3.png',
                                      width: 45,
                                      height: 105,
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
      ),

      // ══════════════════════
      // BOTTOM NAV
      // ══════════════════════
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            _buildNavItem("assets/images/icons/home.png", "Home"),
            _buildNavItem("assets/images/icons/services.png", "Services"),
            _buildNavItem("assets/images/icons/chat.png", "Chat"),
            _buildNavItem("assets/images/icons/bookings.png", "Bookings"),
            _buildNavItem("assets/images/icons/profile.png", "Profile"),
          ],
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
            child: const Icon(Icons.person,
                color: Colors.white54, size: 32),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Image.asset(iconPath, width: 24, height: 24),
      ),
      label: label,
    );
  }
}