// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../pages/filter_page.dart';
import '../pages/service_detail_page.dart';
import '../widgets/feature_item.dart';
import '../widgets/filter_button.dart';
import '../widgets/category_card.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/my_services_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/services_model.dart';

class HomeContent extends StatefulWidget {
  // ✅ TAMBAH: callback ke HomePage saat kategori dipencet
  final void Function(String category)? onCategoryTap;

  const HomeContent({super.key, this.onCategoryTap}); // ✅ UBAH constructor

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final HomeController _controller = HomeController();
  final AuthController _controllerAuth = AuthController();
  final MyServicesController _servicesController = MyServicesController();

  List<ServiceModel> _filteredServices = [];
  int? _selectedCategoryGridIndex;
  int? _activePriceIndex;

  final List<Map<String, dynamic>> _priceRanges = [
    {'label': 'Rp 0 - 50.000', 'min': 0.0, 'max': 50000.0},
    {'label': 'Rp 51.000 - 100.000', 'min': 51000.0, 'max': 100000.0},
    {'label': 'Rp 101.000 - 150.000', 'min': 101000.0, 'max': 150000.0},
    {'label': 'Rp 151.000 - 200.000', 'min': 151000.0, 'max': 200000.0},
    {'label': 'Rp 201.000 - 250.000', 'min': 201000.0, 'max': 250000.0},
    {'label': 'Rp 251.000 - 300.000', 'min': 251000.0, 'max': 300000.0},
    {'label': 'Rp 301.000 - 350.000', 'min': 301000.0, 'max': 350000.0},
    {'label': 'Rp 351.000 - 400.000', 'min': 351000.0, 'max': 400000.0},
    {'label': 'Rp 401.000 - 450.000', 'min': 401000.0, 'max': 450000.0},
  ];

  @override
  void initState() {
    super.initState();
    _filteredServices = _servicesController.services;
  }

  void _filterByCategoryButton(int index) {
    final categories = _controller.getCategories();
    final all = _servicesController.services;

    setState(() {
      if (_selectedCategoryGridIndex == index) {
        _selectedCategoryGridIndex = null;
        _filteredServices = all;
        return;
      }

      _selectedCategoryGridIndex = index;
      final selectedCat = categories[index].title.toLowerCase();

      _filteredServices = all.where((service) {
        final serviceCategory = service.category.toLowerCase();
        final serviceTitle = service.title.toLowerCase();
        return serviceCategory.contains(selectedCat) ||
            serviceTitle.contains(selectedCat);
      }).toList();
    });
  }

  void _applyBottomSheetFilter(Map<String, dynamic> result) {
    final categoryIndex = result['categoryIndex'] as int?;
    final priceIndex = result['priceIndex'] as int?;
    final all = _servicesController.services;
    final categories = _controller.getCategories();

    setState(() {
      _selectedCategoryGridIndex = categoryIndex;
      _activePriceIndex = priceIndex;

      if (categoryIndex == null && priceIndex == null) {
        _filteredServices = all;
        return;
      }

      _filteredServices = all.where((service) {
        bool matchCategory = true;
        if (categoryIndex != null && categoryIndex < categories.length) {
          final selectedCat = categories[categoryIndex].title.toLowerCase();
          matchCategory =
              service.category.toLowerCase().contains(selectedCat) ||
              service.title.toLowerCase().contains(selectedCat);
        }

        bool matchPrice = true;
        if (priceIndex != null && priceIndex < _priceRanges.length) {
          final rawPrice =
              double.tryParse(
                service.basicPackage.price
                    .replaceAll('Rp', '')
                    .replaceAll('.', '')
                    .replaceAll(' ', '')
                    .trim(),
              ) ??
              0;

          final min = _priceRanges[priceIndex]['min'] as double;
          final max = _priceRanges[priceIndex]['max'] as double?;

          matchPrice = rawPrice >= min && (max == null || rawPrice <= max);
        }

        return matchCategory && matchPrice;
      }).toList();
    });
  }

  void _resetAllFilters() {
    setState(() {
      _selectedCategoryGridIndex = null;
      _activePriceIndex = null;
      _filteredServices = _servicesController.services;
    });
  }

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
              // HEADER
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
                    onTap: () async {
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const FilterSheet(),
                          );

                      if (result != null) {
                        _applyBottomSheetFilter(result);
                      }
                    },
                  ),
                ],
              ),

              if (_selectedCategoryGridIndex != null ||
                  _activePriceIndex != null)
                Padding(
                  padding: EdgeInsets.only(top: s(10)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        size: 14,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filter aktif • ${_filteredServices.length} hasil',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _resetAllFilters,
                        child: const Text(
                          'Hapus filter',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: s(28)),

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

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                crossAxisSpacing: s(12),
                mainAxisSpacing: s(12),
                childAspectRatio: 2.2,
                // ✅ UBAH: dari asMap().entries → panggil onCategoryTap ke HomePage
                children: categories.map((cat) {
                  return CategoryCard(
                    category: cat,
                    onTap: () {
                      // ✅ UBAH: tidak filter di Home, tapi pindah ke ServicesPage
                      widget.onCategoryTap?.call(cat.title);
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: s(28)),

              Text(
                "Recommend For You",
                style: TextStyle(
                  fontSize: s(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: s(12)),

              if (_filteredServices.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: s(24)),
                  child: Center(
                    child: Text(
                      'Tidak ada service yang sesuai filter',
                      style: TextStyle(fontSize: s(13), color: Colors.black45),
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: _filteredServices.map((svc) {
                      return ServiceCard(
                        service: svc,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailPage(service: svc),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),

              SizedBox(height: s(24)),

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
