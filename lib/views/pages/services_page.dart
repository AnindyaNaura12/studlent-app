import 'package:flutter/material.dart';
import '/controllers/services_controller.dart';
import '/controllers/home_controller.dart';
import '/models/services_model.dart';
import '../widgets/categori_item.dart';
import '../widgets/freelancer_card.dart';
import '../widgets/freelancer_card_horizontal.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int selectedIndex = 0;

  // Inisialisasi controller sekali saja di sini, bukan di dalam build()
  final _homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final services = ServiceController.getServices();
    final categories = _homeController.getCategories();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: SingleChildScrollView(
          // Mencegah garis hitam / glow effect di Android
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: s(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: s(20)),

              // ================= HEADER =================
              Text(
                "Hi, Nafila 👋",
                style: TextStyle(
                  fontSize: s(24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Find the right student service for you",
                style: TextStyle(fontSize: s(13), color: Colors.black54),
              ),

              SizedBox(height: s(20)),

              // ================= SEARCH =================
              TextField(
                style: TextStyle(fontSize: s(14)),
                decoration: InputDecoration(
                  hintText: "What you're looking for?",
                  hintStyle: TextStyle(fontSize: s(13), color: Colors.grey),
                  prefixIcon: Icon(Icons.search, size: s(20)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: s(14)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(s(30)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: s(24)),

              // ================= CATEGORY TITLE =================
              Text(
                "Service Categories",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: s(18),
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: s(10)),

              // ================= CATEGORY LIST =================
              SizedBox(
                height: s(100),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // ClampingScrollPhysics untuk horizontal list juga
                  physics: const ClampingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return CategoryItem(
                      title: cat.title,
                      iconPath: cat.iconPath,
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: s(20)),

              // ================= RECOMMENDED TITLE =================
              Text(
                "Recommended For You",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: s(18),
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: s(10)),

              // ================= RECOMMENDED LIST =================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return FreelancerCardHorizontal(service: services[index]);
                },
              ),

              SizedBox(height: s(16)),

              // ================= POPULAR TITLE =================
              Text(
                "Popular Services",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: s(18),
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: s(10)),

              // ================= POPULAR LIST =================
              SizedBox(
                // Pakai screenWidth-based height agar proporsional di semua layar
                height: screenWidth * 0.85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(service: services[index]);
                  },
                ),
              ),

              SizedBox(height: s(20)),
            ],
          ),
        ),
      ),
    );
  }
}
