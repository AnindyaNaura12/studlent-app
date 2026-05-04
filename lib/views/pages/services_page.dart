import 'package:flutter/material.dart';
import '/controllers/my_services_controller.dart'; // ← UBAH import
import '/controllers/home_controller.dart';
import '/models/services_model.dart';
import '../widgets/filter_button.dart';
import '../widgets/freelancer_card.dart';
import '../widgets/freelancer_card_horizontal.dart';
import '../pages/service_detail_page.dart';
import '../pages/filter_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int selectedIndex = 0;

  // ← PINDAH KE SINI, bukan di dalam build()
  final _homeController = HomeController();
  final _servicesController = MyServicesController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    // ← UBAH: ambil dari _servicesController.services
    final services = _servicesController.services;
    final categories = _homeController.getCategories();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: SingleChildScrollView(
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(fontSize: s(14)),
                      decoration: InputDecoration(
                        hintText: "What you're looking for?",
                        hintStyle: TextStyle(
                          fontSize: s(13),
                          color: Colors.grey,
                        ),
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
                  ),
                  SizedBox(width: s(10)),
                  FilterButton(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const FilterSheet(),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: s(24)),

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
                  return FreelancerCardHorizontal(
                    service: services[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ServiceDetailPage(service: services[index]),
                        ),
                      );
                    },
                  );
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
                height: screenWidth * 0.85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(
                      service: services[index],
                      onTap: () {                          // ← TAMBAH INI
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(service: services[index]),
                          ),
                        );
                      },
                    );
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
