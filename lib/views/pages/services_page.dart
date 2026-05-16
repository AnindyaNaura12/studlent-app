// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/controllers/my_services_controller.dart';
import '/controllers/home_controller.dart';
import '/models/services_model.dart';
import '../widgets/filter_button.dart';
import '../widgets/freelancer_card.dart';
import '../widgets/freelancer_card_horizontal.dart';
import '../pages/service_detail_page.dart';
import '../pages/filter_page.dart';
import '../../main.dart';

class ServicesPage extends StatefulWidget {
  final String? initialCategory;

  const ServicesPage({super.key, this.initialCategory});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int selectedIndex = 0;

  final _homeController = HomeController();
  final _servicesController = MyServicesController();
  final _supabase = Supabase.instance.client;

  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoggedIn = false;

  List<ServiceModel> _filteredServices = [];
  int? _activeCategoryIndex;
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

    // auto-filter saat pertama dibuka dengan kategori dari Home
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filterByCategory(widget.initialCategory!);
      });
    }

    _loadUserName();

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      _loadUserName();
    });
  }

  // ✅ TAMBAH: deteksi perubahan initialCategory dari IndexedStack
  @override
  void didUpdateWidget(covariant ServicesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialCategory != oldWidget.initialCategory) {
      if (widget.initialCategory != null) {
        // kategori baru dipilih dari Home → filter
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _filterByCategory(widget.initialCategory!);
        });
      } else {
        // initialCategory dikosongkan → reset semua filter
        setState(() {
          _activeCategoryIndex = null;
          _activePriceIndex = null;
          _filteredServices = _servicesController.services;
        });
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // ✅ Filter berdasarkan nama kategori (dipanggil dari Home)
  void _filterByCategory(String categoryTitle) {
    final all = _servicesController.services;
    final selectedCat = categoryTitle.toLowerCase();

    // DEBUG: cek nilai category di data — hapus setelah fix
    debugPrint('🔍 Filter by: "$selectedCat"');
    for (final s in all) {
      debugPrint('   service.category = "${s.category.toLowerCase()}"');
    }

    setState(() {
      _filteredServices = all.where((service) {
        return service.category.toLowerCase().contains(selectedCat) ||
            service.title.toLowerCase().contains(selectedCat);
      }).toList();

      debugPrint('✅ Hasil filter: ${_filteredServices.length} service');
    });
  }

  Future<void> _loadUserName() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      setState(() => _isLoggedIn = false);
      globalUsername.value = '';
      return;
    }

    setState(() => _isLoggedIn = true);

    try {
      final email = _supabase.auth.currentUser?.email;
      if (email == null) return;

      final data = await _supabase
          .from('users')
          .select('username')
          .eq('email', email)
          .maybeSingle();

      if (data != null && mounted) {
        globalUsername.value = data['username'] as String? ?? 'Student';
      }
    } catch (_) {
      globalUsername.value = '';
    }
  }

  void _applyFilter(Map<String, dynamic> result) {
    final categoryIndex = result['categoryIndex'] as int?;
    final priceIndex = result['priceIndex'] as int?;
    final all = _servicesController.services;
    final categories = _homeController.getCategories();

    setState(() {
      _activeCategoryIndex = categoryIndex;
      _activePriceIndex = priceIndex;

      if (categoryIndex == null && priceIndex == null) {
        _filteredServices = all;
        return;
      }

      _filteredServices = all.where((service) {
        bool matchCategory = true;
        if (categoryIndex != null && categoryIndex < categories.length) {
          final selectedCat = categories[categoryIndex].title.toLowerCase();
          matchCategory = service.category.toLowerCase().contains(selectedCat);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

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

              // ── HEADER ──
              ValueListenableBuilder<String>(
                valueListenable: globalUsername,
                builder: (context, username, _) {
                  final greeting = username.isNotEmpty ? username : 'People';
                  return Text(
                    "Hi, $greeting 👋",
                    style: TextStyle(
                      fontSize: s(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                },
              ),

              // subtitle: tampil nama kategori jika dari Home, biasa jika tidak
              if (widget.initialCategory != null)
                Padding(
                  padding: EdgeInsets.only(top: s(2)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kategori: ${widget.initialCategory}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  "Find the right student service for you",
                  style: TextStyle(fontSize: s(13), color: Colors.black54),
                ),

              SizedBox(height: s(20)),

              // ── SEARCH + FILTER ──
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
                    onTap: () async {
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const FilterSheet(),
                          );
                      if (result != null) {
                        _applyFilter(result);
                      }
                    },
                  ),
                ],
              ),

              if (_activeCategoryIndex != null || _activePriceIndex != null)
                Padding(
                  padding: EdgeInsets.only(top: s(8)),
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
                        onTap: () {
                          setState(() {
                            _activeCategoryIndex = null;
                            _activePriceIndex = null;
                            _filteredServices = _servicesController.services;
                          });
                        },
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

              SizedBox(height: s(24)),

              // ── RECOMMENDED ──
              Text(
                "Recommended For You",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: s(18),
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: s(10)),

              if (_filteredServices.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: s(30)),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: s(48),
                          color: Colors.black26,
                        ),
                        SizedBox(height: s(8)),
                        Text(
                          'Tidak ada service yang sesuai filter',
                          style: TextStyle(
                            fontSize: s(13),
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredServices.length,
                  itemBuilder: (context, index) {
                    return FreelancerCardHorizontal(
                      service: _filteredServices[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(
                              service: _filteredServices[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

              SizedBox(height: s(16)),

              if (_filteredServices.isNotEmpty) ...[
                Text(
                  "Popular Services",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: s(18),
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: s(10)),
                SizedBox(
                  height: screenWidth * 0.85,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      return ServiceCard(
                        service: _filteredServices[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailPage(
                                service: _filteredServices[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: s(20)),
            ],
          ),
        ),
      ),
    );
  }
}
