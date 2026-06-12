// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/service_detail_page.dart' as service_page;
import '../widgets/feature_item.dart';
import '../widgets/category_card.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/my_services_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/services_model.dart';
import '../../models/category_model.dart';

class HomeContent extends StatefulWidget {
  final void Function(String category)? onCategoryTap;
  final VoidCallback? onProfileTap;
  final void Function(int index, {String? category})? onGlobalSearchNavigate;

  const HomeContent({
    super.key,
    this.onCategoryTap,
    this.onProfileTap,
    this.onGlobalSearchNavigate,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final HomeController _controller = HomeController();
  final AuthController _controllerAuth = AuthController();
  final MyServicesController _servicesController = MyServicesController();
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<ServiceModel> _filteredServices = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<CategoryModel> _categories = [];
  String? _profileImageUrl;
  bool _isLoggedIn = false;
  bool _isLoadingRecommend = true;
  String _searchQuery = '';
  String? _userInterest;

  @override
  void initState() {
    super.initState();
    _filteredServices = _servicesController.services;
    _loadCategories();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await _controller.getHomeCategories();
    if (mounted) setState(() => _categories = cats);
  }

  Future<void> _loadUserData() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _profileImageUrl = null;
        _isLoadingRecommend = false;
      });
      return;
    }

    try {
      final data = await _supabase
          .from('users')
          .select('id_user, email, foto, product_interest')
          .eq('email', user.email!)
          .maybeSingle();

      if (!mounted) return;

      final imageUrl = data?['foto'] as String?;
      final interest = data?['product_interest'] as String?;

      // Fetch services berdasarkan interest
      if (interest != null && interest.trim().isNotEmpty) {
        await _servicesController.fetchServices(category: interest);
      } else {
        await _servicesController.fetchServices();
      }

      setState(() {
        _isLoggedIn = true;
        _userInterest = interest;
        _profileImageUrl = imageUrl != null && imageUrl.trim().isNotEmpty
            ? imageUrl
            : null;
        _filteredServices = List<ServiceModel>.from(
          _servicesController.services,
        );
        _isLoadingRecommend = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = true;
        _profileImageUrl = null;
        _isLoadingRecommend = false;
      });
    }
  }

  void _handleProfileTap() {
    if (!_isLoggedIn) {
      _controllerAuth.goToRegisterCover(context);
      return;
    }

    widget.onProfileTap?.call();
  }

  String _safe(dynamic value) {
    if (value == null) return '';
    return value.toString().toLowerCase();
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll('/', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _getSearchItemImage(Map<String, dynamic> item) {
    final type = (item['type'] ?? '').toString().toLowerCase();
    final rawTitle = (item['title'] ?? '').toString();
    final rawSubtitle = (item['subtitle'] ?? '').toString();

    final title = _normalizeText(rawTitle);
    final subtitle = _normalizeText(rawSubtitle);
    final combined = '$title $subtitle';

    if (type == 'page') {
      if (title == 'home') return 'assets/images/icons/home.png';
      if (title == 'services') return 'assets/images/icons/services.png';
      if (title == 'chat') return 'assets/images/icons/chat.png';
      if (title == 'my orders') return 'assets/images/icons/bookings.png';
      if (title == 'my profile') return 'assets/images/icons/profile.png';
      return 'assets/images/icons/services.png';
    }

    if (type == 'category') {
      if (title == 'website development') {
        return 'assets/images/icons/website_development.png';
      }
      if (title == 'graphic design') {
        return 'assets/images/icons/graphic_design.png';
      }
      if (title == 'photography') {
        return 'assets/images/icons/photography.png';
      }
      if (title == 'video editing') {
        return 'assets/images/icons/video_editing.png';
      }
      if (title == 'image editing') {
        return 'assets/images/icons/image_editing.png';
      }
      if (title == 'writing and translation' ||
          title == 'writing translation') {
        return 'assets/images/icons/writing_translation.png';
      }

      return 'assets/images/icons/services.png';
    }

    if (type == 'service') {
      if (combined.contains('website development') ||
          combined.contains('website') ||
          combined.contains('web development')) {
        return 'assets/images/icons/website_development.png';
      }

      if (combined.contains('graphic design') ||
          combined.contains('graphic') ||
          combined.contains('design')) {
        return 'assets/images/icons/graphic_design.png';
      }

      if (combined.contains('photography') || combined.contains('photo')) {
        return 'assets/images/icons/photography.png';
      }

      if (combined.contains('video editing') || combined.contains('video')) {
        return 'assets/images/icons/video_editing.png';
      }

      if (combined.contains('image editing') || combined.contains('image')) {
        return 'assets/images/icons/image_editing.png';
      }

      if (combined.contains('writing and translation') ||
          combined.contains('writing translation') ||
          combined.contains('writing') ||
          combined.contains('translation')) {
        return 'assets/images/icons/writing_translation.png';
      }

      return 'assets/images/icons/services.png';
    }

    return 'assets/images/icons/services.png';
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      _searchQuery = value;

      if (query.isEmpty) {
        _searchResults = [];
        return;
      }

      final categories = _controller.getCategories();

      final List<Map<String, dynamic>> pageTargets = [
        {
          'title': 'Home',
          'subtitle': 'Go to Home page',
          'type': 'page',
          'index': 0,
          'keywords': 'home main dashboard studlent',
        },
        {
          'title': 'Services',
          'subtitle': 'Go to Services page',
          'type': 'page',
          'index': 1,
          'keywords': 'services service freelancer job jasa category kategori',
        },
        {
          'title': 'Chat',
          'subtitle': 'Go to Chat page',
          'type': 'page',
          'index': 2,
          'keywords': 'chat message messages inbox pesan',
        },
        {
          'title': 'My Orders',
          'subtitle': 'Go to My Orders page',
          'type': 'page',
          'index': 3,
          'keywords': 'orders bookings pesanan transaksi order booking',
        },
        {
          'title': 'My Profile',
          'subtitle': 'Go to Profile page',
          'type': 'page',
          'index': 4,
          'keywords': 'profile profil akun account my profile saya',
        },
      ];

      final categoryTargets = _categories.map((cat) {
        return {
          'title': cat.title,
          'subtitle': 'Category in Services',
          'type': 'category',
          'index': 1,
          'category': cat.title,
          'keywords': '${cat.title.toLowerCase()} category service jasa',
        };
      }).toList();

      final serviceTargets = _servicesController.services.map((service) {
        final extraKeywords = [
          _safe(service.title),
          _safe(service.category),
          _safe(service.basicPackage.price),
        ].join(' ');

        return {
          'title': service.title,
          'subtitle': 'Service • ${service.category}',
          'type': 'service',
          'service': service,
          'keywords': extraKeywords,
        };
      }).toList();

      final allTargets = [
        ...pageTargets,
        ...categoryTargets,
        ...serviceTargets,
      ];

      _searchResults = allTargets
          .where((item) {
            final title = _safe(item['title']);
            final subtitle = _safe(item['subtitle']);
            final keywords = _safe(item['keywords']);

            return title.contains(query) ||
                subtitle.contains(query) ||
                keywords.contains(query);
          })
          .take(10)
          .toList();
    });
  }

  void _handleSearchItemTap(Map<String, dynamic> item) {
    final type = item['type'];

    if (type == 'page') {
      widget.onGlobalSearchNavigate?.call(item['index'] as int);
    } else if (type == 'category') {
      widget.onGlobalSearchNavigate?.call(
        item['index'] as int,
        category: item['category'] as String,
      );
    } else if (type == 'service') {
      final service = item['service'] as ServiceModel;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => service_page.ServiceDetailPage(service: service),
        ),
      );
    }

    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _searchResults = [];
    });
  }

  Widget _buildProfileAvatar(double Function(double) s) {
    final hasImage =
        _profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTap: _handleProfileTap,
      child: Container(
        width: s(44),
        height: s(44),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.orange.withOpacity(0.18), width: 1),
        ),
        child: hasImage
            ? ClipOval(
                child: Image.network(
                  _profileImageUrl!,
                  width: s(44),
                  height: s(44),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Icon(Icons.person, size: s(22), color: Colors.grey);
                  },
                ),
              )
            : Icon(Icons.person, size: s(22), color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_studlent.png',
                        height: s(40),
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.school,
                          size: s(40),
                          color: Colors.orange,
                        ),
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
                              Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: s(20),
                              ),
                              SizedBox(width: s(8)),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  style: TextStyle(fontSize: s(13)),
                                  decoration: InputDecoration(
                                    hintText: "Search all pages...",
                                    border: InputBorder.none,
                                    suffixIcon: _searchQuery.trim().isNotEmpty
                                        ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _searchController.clear();
                                                _searchQuery = '';
                                                _searchResults = [];
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              size: s(18),
                                              color: Colors.grey,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: s(10)),
                      _buildProfileAvatar(s),
                    ],
                  ),

                  if (_searchResults.isNotEmpty) ...[
                    SizedBox(height: s(10)),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxHeight: s(320)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(s(18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(s(18)),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: s(6)),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            final String imagePath = _getSearchItemImage(item);

                            return InkWell(
                              onTap: () => _handleSearchItemTap(item),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: s(16),
                                  vertical: s(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: s(42),
                                      height: s(42),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF8EE),
                                        borderRadius: BorderRadius.circular(
                                          s(12),
                                        ),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(
                                            0.15,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(s(8)),
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) {
                                          return Image.asset(
                                            'assets/images/icons/services.png',
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: s(12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'],
                                            style: TextStyle(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: s(4)),
                                          Text(
                                            item['subtitle'],
                                            style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.black54,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: s(8)),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: s(14),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
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
                children: _categories.map((cat) {
                  return CategoryCard(
                    category: cat,
                    onTap: () {
                      widget.onCategoryTap?.call(cat.title);
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: s(28)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recommend For You",
                    style: TextStyle(
                      fontSize: s(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_userInterest != null)
                    Text(
                      _userInterest!,
                      style: TextStyle(
                        fontSize: s(12),
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

              SizedBox(height: s(12)),

              if (_filteredServices.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: s(24)),
                  child: Center(
                    child: Text(
                      'Tidak ada service yang tersedia',
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
                              builder: (_) =>
                                  service_page.ServiceDetailPage(service: svc),
                            ),
                          );
                        },
                      );
                    }).toList(),
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
