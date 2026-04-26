import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/services_controller.dart';
import '../../controllers/auth_controller.dart';
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
  final AuthController _controllerAuth = AuthController();

  @override
  Widget build(BuildContext context) {
    final categories = _controller.getCategories();
    final services = ServiceController.getServices();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 🔥 RESPONSIVE SCALE (biar gak over)
    double scale(double size) => size * (screenWidth / 375);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: scale(24),
            vertical: scale(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HEADER
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_studlent.png',
                    height: scale(40),
                  ),
                  SizedBox(width: scale(12)),

                  Expanded(
                    child: Container(
                      height: scale(45),
                      padding: EdgeInsets.symmetric(horizontal: scale(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(scale(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: scale(6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: scale(8)),
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

                  SizedBox(width: scale(10)),

                  Container(
                    padding: EdgeInsets.all(scale(10)),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(scale(10)),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: scale(30)),

              // HERO TEXT
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: scale(26),
                      fontWeight: FontWeight.bold,
                      height: 1.3, // ✅ FIXED
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

              SizedBox(height: scale(10)),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Text(
                    "Connect with skilled students ready to deliver quality work, fast and affordable",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: scale(14),
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: scale(20)),

              // HERO IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(scale(20)),
                child: Image.asset(
                  'assets/images/hero_student.png',
                  width: double.infinity,
                  height: screenHeight * 0.25, // ✅ lebih masuk akal
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: scale(25)),

              // WHY CHOOSE
              Center(
                child: Text(
                  "Why Choose Student Talent?",
                  style: TextStyle(
                    fontSize: scale(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: scale(16)),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FeatureItem(iconPath: "assets/images/icons/faster_delivery.png", label: "Faster\nDelivery"),
                  FeatureItem(iconPath: "assets/images/icons/student_pricing.png", label: "Student\nPricing"),
                  FeatureItem(iconPath: "assets/images/icons/verified_portofolios.png", label: "Verified Student\nPortfolios"),
                  FeatureItem(iconPath: "assets/images/icons/secure_payments.png", label: "Secure\nPayments"),
                ],
              ),

              SizedBox(height: scale(30)),

              // CATEGORY
              Center(
                child: Text(
                  "Service Categories",
                  style: TextStyle(
                    fontSize: scale(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: scale(20)),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                crossAxisSpacing: scale(12),
                mainAxisSpacing: scale(12),
                childAspectRatio: 2.2,
                children: categories
                    .map((cat) => CategoryCard(category: cat))
                    .toList(),
              ),

              SizedBox(height: scale(30)),

              // SERVICES
              Text(
                "Recommend For You",
                style: TextStyle(
                  fontSize: scale(16),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: scale(12)),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: services
                      .map((s) => ServiceCard(service: s))
                      .toList(),
                ),
              ),

              SizedBox(height: scale(20)),

              // CTA
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(scale(20)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(scale(20)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Make It All Happen",
                        style: TextStyle(
                          fontSize: scale(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _controllerAuth.goToRegisterCover(context);
                      },
                      child: Text(
                        "Join Now",
                        style: TextStyle(fontSize: scale(14)),
                      ),
                    ),
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