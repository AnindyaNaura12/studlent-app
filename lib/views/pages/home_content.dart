import 'package:flutter/material.dart';
import '../pages/filter_page.dart';
import '../widgets/feature_item.dart';
import '../widgets/filter_button.dart';
import '../widgets/category_card.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/my_services_controller.dart'; // ← UBAH
import '../../controllers/auth_controller.dart';
import '../../models/services_model.dart' as model1;

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final HomeController _controller = HomeController();
  final AuthController _controllerAuth = AuthController();
  final MyServicesController _servicesController =
      MyServicesController(); // ← PINDAH KE SINI

  @override
  Widget build(BuildContext context) {
    final categories = _controller.getCategories();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_studlent.png',
                    height: s(40),
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.school, size: s(40), color: Colors.orange),
                  ),
                  SizedBox(width: s(12)),
                  Expanded(
                    child: Container(
                      height: s(45),
                      padding: EdgeInsets.symmetric(horizontal: s(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(s(12)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: s(20)),
                          SizedBox(width: s(8)),
                          Expanded(
                            child: TextField(
                              style: TextStyle(fontSize: s(13)),
                              decoration: const InputDecoration(
                                hintText: "Search services...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
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

              SizedBox(height: s(28)),

              // ================= HERO TEXT =================
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: s(24),
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black,
                    ),
                    children: const [
                      TextSpan(text: "Turn Student Talent\nInto Your "),
                      TextSpan(
                        text: "Best Solution",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: s(10)),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Text(
                    "Connect with skilled students ready to deliver quality work, fast and affordable",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: s(13),
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: s(20)),

              // ================= HERO IMAGE =================
              ClipRRect(
                borderRadius: BorderRadius.circular(s(20)),
                child: Image.asset(
                  'assets/images/hero_student.png',
                  width: double.infinity,
                  height: screenHeight * 0.25,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(s(20)),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.orange,
                      size: s(40),
                    ),
                  ),
                ),
              ),

              SizedBox(height: s(24)),

              // ================= WHY CHOOSE =================
              Center(
                child: Text(
                  "Why Choose Student Talent?",
                  style: TextStyle(
                    fontSize: s(17),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: s(16)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    label: "Verified\nPortfolios",
                  ),
                  FeatureItem(
                    iconPath: "assets/images/icons/secure_payments.png",
                    label: "Secure\nPayments",
                  ),
                ],
              ),

              SizedBox(height: s(28)),

              // ================= CATEGORY TITLE =================
              Center(
                child: Text(
                  "Service Categories",
                  style: TextStyle(
                    fontSize: s(17),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: s(16)),

              // ================= CATEGORY GRID =================
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                crossAxisSpacing: s(12),
                mainAxisSpacing: s(12),
                childAspectRatio: 2.2,
                children: categories
                    .map((cat) => CategoryCard(category: cat))
                    .toList(),
              ),

              SizedBox(height: s(28)),

              // ================= SERVICES TITLE =================
              Text(
                "Recommend For You",
                style: TextStyle(
                  fontSize: s(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: s(12)),

              // ================= SERVICES LIST =================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: _servicesController.services
                      .map(
                        (svc) =>
                            ServiceCard(service: svc as model1.ServiceModel),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: s(24)),

              // ================= CTA BANNER =================
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(s(20)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(s(20)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Make It All Happen",
                            style: TextStyle(
                              fontSize: s(17),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: s(6)),
                          Text(
                            "Connect with skilled students and get your work done faster.",
                            style: TextStyle(
                              fontSize: s(12),
                              color: Colors.black87.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: s(12)),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _controllerAuth.goToRegisterCover(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          padding: EdgeInsets.symmetric(
                            horizontal: s(16),
                            vertical: s(12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(14)),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Start Now",
                          style: TextStyle(
                            fontSize: s(13),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: s(16)),
            ],
          ),
        ),
      ),
    );
  }
}
