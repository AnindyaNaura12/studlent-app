import 'package:flutter/material.dart';
import '../widgets/feature_item.dart';
import '../widgets/category_card.dart';

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

              // ======================
              // 🔵 HEADER
              // ======================
              Row(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo_studlent.png',
                    height: 40, // Atur tinggi sesuai kebutuhan desainmu
                    fit: BoxFit.contain, // Agar gambar tidak terpotong dan tetap proporsional
                  ),

                  const SizedBox(width: 20),

                  // Search Bar
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
                          )
                        ],
                      ),

                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),

                          const SizedBox(width: 10),

                          const Expanded(
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

                  // Filter Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 40),

              // ======================
              // 🔵 HERO SECTION (TEXT ONLY)
              // ======================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔵 Headline
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 700),
                      child: Text(
                        "Turn Student Talent Into Your Best Solution.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔵 Sub-headline
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                      child: Text(
                        "Connect with skilled students ready to deliver quality work, fast and affordable",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),

                      const SizedBox(height: 30),

                  ],
                ),

              // ======================
              // 🟣 IMAGE SECTION
              // ======================

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 900),
                    child: Image.asset(
                      'assets/images/hero_student.png', 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              // ======================
              // 🔵 WHY CHOOSE SECTION
              // ======================

              Center(
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

              // Baris Ikon Fitur
              Row(
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

              // ======================
              // 🔵 SERVICE CATEGORIES SECTION
              // ======================
              const SizedBox(height: 25),

              Center(
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

              // Grid Kategori
              GridView.count(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                crossAxisCount: 2, // 2 Kolom
                crossAxisSpacing: 16, // Jarak horizontal antar kotak
                mainAxisSpacing: 16, // Jarak vertikal antar kotak
                childAspectRatio: 2.1, // Mengatur rasio lebar vs tinggi kotak (persegi panjang)
                children: [
                  CategoryCard(
                    title: "Website\nDevelopment", 
                    iconPath: "assets/images/categories/website_development.png"
                    ),
                  CategoryCard(
                    title: "Graphic Design", 
                    iconPath: "assets/images/categories/graphic_design.png"
                    ),
                  CategoryCard(
                    title: "Photography", 
                    iconPath: "assets/images/categories/photography.png"
                    ),
                  CategoryCard(
                    title: "Video Editing", 
                    iconPath: "assets/images/categories/video_editing.png"
                    ),
                  CategoryCard(
                    title: "Image Editing", 
                    iconPath: "assets/images/categories/image_editing.png"
                    ),
                  CategoryCard(
                    title: "Writing &\nTranslation", 
                    iconPath: "assets/images/categories/writing_translation.png"
                    ),
                ],
              ),
              
            ],
          ),
        ),
      ),
      ),

      // ======================
      // 🔵 BOTTOM NAVIGATION BAR
      // ======================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Penting agar lebih dari 3 menu tidak bergeser
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,   // Warna saat menu dipilih
          unselectedItemColor: Colors.grey,  // Warna saat menu tidak dipilih
          showSelectedLabels: true,          // Menampilkan teks "Home", "Chat", dll
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
  return BottomNavigationBarItem(
    icon: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        // Tips: Gunakan color: Colors.grey jika ingin mewarnai gambar aset secara dinamis
      ),
    ),
    label: label,
  );

}

}