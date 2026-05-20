// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/controllers/my_services_controller.dart';
import '/controllers/home_controller.dart';
import '/models/services_model.dart';
import '../widgets/filter_button.dart';
import '../widgets/freelancer_card_horizontal.dart';
import '../widgets/service_card.dart';
import '../pages/service_detail_page.dart';
import '../pages/filter_page.dart';
import '../pages/all_services_page.dart';
import '../pages/popular_services_page.dart';
import '../../main.dart';

class ServicesPage extends StatefulWidget {
  final String? initialCategory;

  const ServicesPage({super.key, this.initialCategory});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final _homeController = HomeController();
  final _servicesController = MyServicesController();
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoggedIn = false;
  String _searchQuery = '';

  List<ServiceModel> _filteredServices = [];
  List<ServiceModel> _randomSuggestedServices = [];
  List<ServiceModel> _popularPreviewServices = [];

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
    _resetAllFilters();

    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetAllFilters(resetSearch: true);
        _applyAllFilters();
      });
    }

    _loadUserName();

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      _loadUserName();
    });
  }

  @override
  void didUpdateWidget(covariant ServicesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialCategory != oldWidget.initialCategory) {
      if (widget.initialCategory != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _resetAllFilters(resetSearch: true);
          _applyAllFilters();
        });
      } else {
        setState(() {
          _resetAllFilters(resetSearch: true);
        });
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _resetAllFilters({bool resetSearch = false}) {
    _activeCategoryIndex = null;
    _activePriceIndex = null;

    if (resetSearch) {
      _searchQuery = '';
      _searchController.clear();
    }

    _filteredServices = _servicesController.services;
    _prepareRandomSuggestions();
    _preparePopularPreview();
  }

  void _prepareRandomSuggestions() {
    final all = List<ServiceModel>.from(_servicesController.services);
    all.shuffle(Random());
    _randomSuggestedServices = all.take(5).toList();
  }

  void _preparePopularPreview() {
    final all = List<ServiceModel>.from(_servicesController.services);
    _popularPreviewServices = all.take(5).toList();
  }

  double _parsePrice(String raw) {
    return double.tryParse(
          raw
              .replaceAll('Rp', '')
              .replaceAll('.', '')
              .replaceAll(' ', '')
              .trim(),
        ) ??
        0;
  }

  String _safe(dynamic value) {
    if (value == null) return '';
    return value.toString().toLowerCase();
  }

  bool _matchesSearch(ServiceModel service, String query) {
    final searchableText = [
      _safe(service.title),
      _safe(service.category),
      _safe(service.basicPackage.price),
    ].join(' ');

    return searchableText.contains(query.toLowerCase());
  }

  void _applyAllFilters() {
    final all = _servicesController.services;
    final categories = _homeController.getCategories();
    final bool fromHomeCategory = widget.initialCategory != null;
    final String query = _searchQuery.trim().toLowerCase();

    setState(() {
      _filteredServices = all.where((service) {
        bool matchCategory = true;
        bool matchPrice = true;
        bool matchSearch = true;

        if (fromHomeCategory) {
          final selectedCat = widget.initialCategory!.toLowerCase();
          matchCategory =
              service.category.toLowerCase().contains(selectedCat) ||
              service.title.toLowerCase().contains(selectedCat);
        } else if (_activeCategoryIndex != null &&
            _activeCategoryIndex! < categories.length) {
          final selectedCat = categories[_activeCategoryIndex!].title
              .toLowerCase();
          matchCategory =
              service.category.toLowerCase().contains(selectedCat) ||
              service.title.toLowerCase().contains(selectedCat);
        }

        if (_activePriceIndex != null &&
            _activePriceIndex! < _priceRanges.length) {
          final rawPrice = _parsePrice(service.basicPackage.price);
          final min = _priceRanges[_activePriceIndex!]['min'] as double;
          final max = _priceRanges[_activePriceIndex!]['max'] as double?;
          matchPrice = rawPrice >= min && (max == null || rawPrice <= max);
        }

        if (query.isNotEmpty) {
          matchSearch = _matchesSearch(service, query);
        }

        return matchCategory && matchPrice && matchSearch;
      }).toList();

      if (!fromHomeCategory &&
          _activeCategoryIndex == null &&
          _activePriceIndex == null &&
          query.isEmpty) {
        _filteredServices = all;
        _prepareRandomSuggestions();
        _preparePopularPreview();
      }
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
    final bool fromHomeCategory = widget.initialCategory != null;
    final int? categoryIndex = fromHomeCategory
        ? null
        : result['categoryIndex'] as int?;
    final int? priceIndex = result['priceIndex'] as int?;

    setState(() {
      _activeCategoryIndex = categoryIndex;
      _activePriceIndex = priceIndex;
    });

    _applyAllFilters();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        onlyPrice: widget.initialCategory != null,
        initialCategoryIndex: widget.initialCategory != null
            ? null
            : _activeCategoryIndex,
        initialPriceIndex: _activePriceIndex,
      ),
    );

    if (result != null) {
      _applyFilter(result);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _applyAllFilters();
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required double Function(double) s,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD6E4FF),
        borderRadius: BorderRadius.circular(s(24)),
      ),
      padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: s(13),
              color: const Color(0xFF3A4252),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: s(8)),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(
              Icons.close,
              size: s(16),
              color: const Color(0xFF5C6470),
            ),
          ),
        ],
      ),
    );
  }

  String? _activeCategoryLabel() {
    if (widget.initialCategory != null) return widget.initialCategory;
    if (_activeCategoryIndex != null) {
      final categories = _homeController.getCategories();
      if (_activeCategoryIndex! < categories.length) {
        return categories[_activeCategoryIndex!].title;
      }
    }
    return null;
  }

  void _removePriceFilter() {
    setState(() {
      _activePriceIndex = null;
    });
    _applyAllFilters();
  }

  void _clearCategoryFilter() {
    setState(() {
      _activeCategoryIndex = null;
      _activePriceIndex = null;
    });
    _applyAllFilters();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _applyAllFilters();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final String sectionTitle = _activeCategoryLabel() ?? 'Suggestion For You';

    final bool isFilterActive =
        _activePriceIndex != null ||
        (widget.initialCategory == null && _activeCategoryIndex != null) ||
        _searchQuery.trim().isNotEmpty;

    final List<ServiceModel> displayedSuggestionServices =
        (widget.initialCategory != null || isFilterActive)
        ? _filteredServices
        : _randomSuggestedServices;

    final String? activeCategoryLabel = _activeCategoryLabel();

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
              Text(
                "Find the right student service for you",
                style: TextStyle(fontSize: s(13), color: Colors.black54),
              ),
              SizedBox(height: s(20)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(fontSize: s(14)),
                      decoration: InputDecoration(
                        hintText: "What you're looking for?",
                        hintStyle: TextStyle(
                          fontSize: s(13),
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(Icons.search, size: s(20)),
                        suffixIcon: _searchQuery.trim().isNotEmpty
                            ? IconButton(
                                onPressed: _clearSearch,
                                icon: Icon(Icons.close, size: s(18)),
                              )
                            : null,
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
                  FilterButton(onTap: _openFilterSheet),
                ],
              ),
              if ((activeCategoryLabel != null &&
                      widget.initialCategory == null) ||
                  _activePriceIndex != null)
                Padding(
                  padding: EdgeInsets.only(top: s(10)),
                  child: Wrap(
                    spacing: s(8),
                    runSpacing: s(8),
                    children: [
                      if (activeCategoryLabel != null &&
                          widget.initialCategory == null)
                        _buildFilterChip(
                          label: activeCategoryLabel,
                          onDeleted: _clearCategoryFilter,
                          s: s,
                        ),
                      if (_activePriceIndex != null)
                        _buildFilterChip(
                          label: _priceRanges[_activePriceIndex!]['label'],
                          onDeleted: _removePriceFilter,
                          s: s,
                        ),
                    ],
                  ),
                ),
              SizedBox(height: s(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: s(18),
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.initialCategory == null)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllServicesPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Show All",
                        style: TextStyle(
                          fontSize: s(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: s(10)),
              if (displayedSuggestionServices.isEmpty)
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
                          'Tidak ada service yang sesuai pencarian / filter',
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
                  itemCount: displayedSuggestionServices.length,
                  itemBuilder: (context, index) {
                    return FreelancerCardHorizontal(
                      service: displayedSuggestionServices[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(
                              service: displayedSuggestionServices[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              if (!isFilterActive && widget.initialCategory == null) ...[
                SizedBox(height: s(16)),
                if (_popularPreviewServices.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Popular Services",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: s(18),
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PopularServicesPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Show All",
                          style: TextStyle(
                            fontSize: s(13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(10)),
                  SizedBox(
                    height: s(320),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _popularPreviewServices.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(
                          service: _popularPreviewServices[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailPage(
                                  service: _popularPreviewServices[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
              SizedBox(height: s(20)),
            ],
          ),
        ),
      ),
    );
  }
}
