// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/controllers/services_controller.dart';
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
  final _servicesController = ServicesController();
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  late final StreamSubscription<AuthState> _authSubscription;
  Timer? _debounce;

  bool _isLoggedIn = false;
  bool _loadingServices = true;

  String _searchQuery = '';
  int? _activeCategoryIndex;
  int? _activePriceIndex;

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  List<ServiceModel> _randomSuggestedServices = [];
  List<ServiceModel> _popularPreviewServices = [];

  final List<Map<String, dynamic>> _priceRanges = [
    {'label': 'Rp 0 - 50.000',       'min': 0.0,      'max': 50000.0},
    {'label': 'Rp 51.000 - 100.000',  'min': 51000.0,  'max': 100000.0},
    {'label': 'Rp 101.000 - 150.000', 'min': 101000.0, 'max': 150000.0},
    {'label': 'Rp 151.000 - 200.000', 'min': 151000.0, 'max': 200000.0},
    {'label': 'Rp 201.000 - 250.000', 'min': 201000.0, 'max': 250000.0},
    {'label': 'Rp 251.000 - 300.000', 'min': 251000.0, 'max': 300000.0},
    {'label': 'Rp 301.000 - 350.000', 'min': 301000.0, 'max': 350000.0},
    {'label': 'Rp 351.000 - 400.000', 'min': 351000.0, 'max': 400000.0},
    {'label': 'Rp 401.000 - 450.000', 'min': 401000.0, 'max': 450000.0},
  ];

  // ─────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchServicesFromDB();
    _authSubscription = _supabase.auth.onAuthStateChange.listen((_) {
      _loadUserName();
    });
  }

  @override
  void didUpdateWidget(covariant ServicesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _activeCategoryIndex = null;
          _activePriceIndex = null;
          _searchQuery = '';
          _searchController.clear();
        });
        _applyAllFilters();
      });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // Data
  // ─────────────────────────────────────────────────────────

  Future<void> _fetchServicesFromDB() async {
    setState(() => _loadingServices = true);
    try {
      final results = await _servicesController.fetchServicesFromSupabase();
      if (mounted) {
        setState(() {
          _allServices = results;
          _loadingServices = false;
        });
        _applyAllFilters();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingServices = false);
    }
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

  // ─────────────────────────────────────────────────────────
  // Filter & Search
  // ─────────────────────────────────────────────────────────

  double _parsePrice(String raw) {
    return double.tryParse(
          raw.replaceAll('Rp', '').replaceAll('.', '').replaceAll(' ', '').trim(),
        ) ??
        0;
  }

  bool _matchesSearch(ServiceModel service, String query) {
    final q = query.toLowerCase();
    return service.title.toLowerCase().contains(q) ||
        service.category.toLowerCase().contains(q) ||
        service.name.toLowerCase().contains(q) ||
        service.description.toLowerCase().contains(q);
  }

  void _applyAllFilters() {
    final all = _allServices;
    final categories = _homeController.getCategories();
    final query = _searchQuery.trim().toLowerCase();

    final filtered = all.where((service) {
      // Category
      bool matchCategory = true;
      if (widget.initialCategory != null) {
        final cat = widget.initialCategory!.toLowerCase();
        matchCategory = service.category.toLowerCase().contains(cat) ||
            service.title.toLowerCase().contains(cat);
      } else if (_activeCategoryIndex != null &&
          _activeCategoryIndex! < categories.length) {
        final cat = categories[_activeCategoryIndex!].title.toLowerCase();
        matchCategory = service.category.toLowerCase().contains(cat) ||
            service.title.toLowerCase().contains(cat);
      }

      // Price
      bool matchPrice = true;
      if (_activePriceIndex != null &&
          _activePriceIndex! < _priceRanges.length) {
        final rawPrice = _parsePrice(service.basicPackage.price);
        final min = _priceRanges[_activePriceIndex!]['min'] as double;
        final max = _priceRanges[_activePriceIndex!]['max'] as double;
        matchPrice = rawPrice >= min && rawPrice <= max;
      }

      // Search
      bool matchSearch = query.isEmpty || _matchesSearch(service, query);

      return matchCategory && matchPrice && matchSearch;
    }).toList();

    final shuffled = List<ServiceModel>.from(filtered)..shuffle(Random());

    setState(() {
      _filteredServices = filtered;
      _randomSuggestedServices = shuffled.take(5).toList();
      _popularPreviewServices = filtered.take(5).toList();
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _searchQuery = value);
      _applyAllFilters();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _applyAllFilters();
  }

  void _removeCategoryFilter() {
    setState(() => _activeCategoryIndex = null);
    _applyAllFilters();
  }

  void _removePriceFilter() {
    setState(() => _activePriceIndex = null);
    _applyAllFilters();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        onlyPrice: widget.initialCategory != null,
        initialCategoryIndex:
            widget.initialCategory != null ? null : _activeCategoryIndex,
        initialPriceIndex: _activePriceIndex,
      ),
    );

    if (result == null) return;

    setState(() {
      if (widget.initialCategory == null) {
        _activeCategoryIndex = result['categoryIndex'] as int?;
      }
      _activePriceIndex = result['priceIndex'] as int?;
    });
    _applyAllFilters();
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────

  String? _activeCategoryLabel() {
    if (widget.initialCategory != null) return widget.initialCategory;
    if (_activeCategoryIndex != null) {
      final cats = _homeController.getCategories();
      if (_activeCategoryIndex! < cats.length) {
        return cats[_activeCategoryIndex!].title;
      }
    }
    return null;
  }

  bool get _isFilterActive =>
      _activePriceIndex != null ||
      (widget.initialCategory == null && _activeCategoryIndex != null) ||
      _searchQuery.trim().isNotEmpty;

  // ─────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final String? activeCategoryLabel = _activeCategoryLabel();
    final String sectionTitle = activeCategoryLabel ?? 'Suggestion For You';

    final List<ServiceModel> displayedServices =
        (widget.initialCategory != null || _isFilterActive)
            ? _filteredServices
            : _randomSuggestedServices;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: _loadingServices
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                        return Text(
                          "Hi, ${username.isNotEmpty ? username : 'People'} 👋",
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

                    // ── SEARCH + FILTER ──
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
                                  fontSize: s(13), color: Colors.grey),
                              prefixIcon: Icon(Icons.search, size: s(20)),
                              suffixIcon: _searchQuery.trim().isNotEmpty
                                  ? IconButton(
                                      onPressed: _clearSearch,
                                      icon: Icon(Icons.close, size: s(18)),
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: s(14)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(s(30)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: s(10)),
                        Stack(
                          children: [
                            FilterButton(onTap: _openFilterSheet),
                            if (_activeCategoryIndex != null ||
                                _activePriceIndex != null)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: s(10),
                                  height: s(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // ── ACTIVE FILTER CHIPS ──
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
                                onDeleted: _removeCategoryFilter,
                                s: s,
                              ),
                            if (_activePriceIndex != null)
                              _buildFilterChip(
                                label: _priceRanges[_activePriceIndex!]
                                    ['label'] as String,
                                onDeleted: _removePriceFilter,
                                s: s,
                              ),
                          ],
                        ),
                      ),

                    SizedBox(height: s(24)),

                    // ── SUGGESTION SECTION ──
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
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AllServicesPage()),
                            ),
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

                    displayedServices.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: s(30)),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off,
                                      size: s(48), color: Colors.black26),
                                  SizedBox(height: s(8)),
                                  Text(
                                    'Tidak ada service yang sesuai',
                                    style: TextStyle(
                                        fontSize: s(13),
                                        color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedServices.length,
                            itemBuilder: (context, index) {
                              return FreelancerCardHorizontal(
                                service: displayedServices[index],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailPage(
                                      service: displayedServices[index],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                    // ── POPULAR SECTION ──
                    if (!_isFilterActive &&
                        widget.initialCategory == null) ...[
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
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PopularServicesPage()),
                              ),
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailPage(
                                      service:
                                          _popularPreviewServices[index],
                                    ),
                                  ),
                                ),
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

  // ─────────────────────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────────────────────

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required double Function(double) s,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0A0),
        borderRadius: BorderRadius.circular(s(24)),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: s(12),
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: s(6)),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(Icons.close, size: s(14), color: Colors.black54),
          ),
        ],
      ),
    );
  }
}