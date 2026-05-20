// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/controllers/services_controller.dart';
import '/controllers/home_controller.dart';
import '../widgets/filter_button.dart';
import '../widgets/freelancer_card.dart';
import '../widgets/freelancer_card_horizontal.dart';
import '../pages/service_detail_page.dart';
import '../pages/filter_page.dart';
import '../../main.dart';
import '../../models/services_model.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final _homeController = HomeController();
  final _servicesController = ServicesController();
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoggedIn = false;

  // ── State filter & search ──
  String _searchQuery = '';
  String? _filteredCategory;
  int? _filteredMinPrice;
  int? _filteredMaxPrice;
  Timer? _debounce;

  // ── Cache hasil fetch ──
  List<ServiceModel> _allServices = [];
  bool _loadingServices = true;

  // Price ranges mapping (index → min, max)
  final List<Map<String, int>> _priceRanges = [
    {'min': 0,      'max': 50000},
    {'min': 51000,  'max': 100000},
    {'min': 101000, 'max': 150000},
    {'min': 151000, 'max': 200000},
    {'min': 201000, 'max': 250000},
    {'min': 251000, 'max': 300000},
    {'min': 301000, 'max': 350000},
    {'min': 351000, 'max': 400000},
    {'min': 401000, 'max': 450000},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchServices();

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      _loadUserName();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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

  // ── Fetch dengan filter aktif ──
  Future<void> _fetchServices() async {
    setState(() => _loadingServices = true);
    final results = await _servicesController.fetchServicesFiltered(
      searchQuery: _searchQuery,
      category: _filteredCategory,
      minPrice: _filteredMinPrice,
      maxPrice: _filteredMaxPrice,
    );
    if (mounted) {
      setState(() {
        _allServices = results;
        _loadingServices = false;
      });
    }
  }

  // ── Search dengan debounce ──
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchQuery = value.trim());
      _fetchServices();
    });
  }

  // ── Buka filter sheet & tangkap hasilnya ──
  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterSheet(),
    );

    if (result == null) return;

    final categoryIndex = result['categoryIndex'] as int?;
    final priceIndex = result['priceIndex'] as int?;

    final categories = _homeController.getCategories();

    setState(() {
      _filteredCategory = categoryIndex != null
          ? categories[categoryIndex].title  // sesuaikan dengan field nama di CategoryModel kamu
          : null;
      _filteredMinPrice =
          priceIndex != null ? _priceRanges[priceIndex]['min'] : null;
      _filteredMaxPrice =
          priceIndex != null ? _priceRanges[priceIndex]['max'] : null;
    });

    _fetchServices();
  }

  bool get _hasActiveFilter =>
      _filteredCategory != null ||
      _filteredMinPrice != null ||
      _searchQuery.isNotEmpty;

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
                        hintStyle:
                            TextStyle(fontSize: s(13), color: Colors.grey),
                        prefixIcon: Icon(Icons.search, size: s(20)),
                        // Tombol clear kalau ada teks
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, size: s(18)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  _fetchServices();
                                },
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
                  // Badge merah kalau filter aktif
                  Stack(
                    children: [
                      FilterButton(onTap: _openFilter),
                      if (_filteredCategory != null || _filteredMinPrice != null)
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
              if (_hasActiveFilter) ...[
                SizedBox(height: s(12)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_filteredCategory != null)
                        _FilterChip(
                          label: _filteredCategory!,
                          onRemove: () {
                            setState(() => _filteredCategory = null);
                            _fetchServices();
                          },
                        ),
                      if (_filteredMinPrice != null)
                        _FilterChip(
                          label:
                              'Rp ${_formatPrice(_filteredMinPrice!)} - ${_formatPrice(_filteredMaxPrice!)}',
                          onRemove: () {
                            setState(() {
                              _filteredMinPrice = null;
                              _filteredMaxPrice = null;
                            });
                            _fetchServices();
                          },
                        ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: s(24)),

              // ── RECOMMENDED ──
              Text(
                _hasActiveFilter ? "Search Results" : "Recommended For You",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: s(18),
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: s(10)),

              _loadingServices
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _allServices.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(s(20)),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off,
                                    size: s(48), color: Colors.grey),
                                SizedBox(height: s(8)),
                                Text(
                                  'Tidak ada service ditemukan',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: s(13)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allServices.length,
                          itemBuilder: (context, index) {
                            return FreelancerCardHorizontal(
                              service: _allServices[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailPage(
                                    service: _allServices[index],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

              SizedBox(height: s(16)),

              // ── POPULAR — hanya tampil kalau tidak ada filter aktif ──
              if (!_hasActiveFilter) ...[
                Text(
                  "Popular Services",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: s(18),
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: s(10)),
                _loadingServices
                    ? const SizedBox.shrink()
                    : _allServices.isEmpty
                        ? const SizedBox.shrink()
                        : SizedBox(
                            height: screenWidth * 0.85,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              itemCount: _allServices.length,
                              itemBuilder: (context, index) {
                                return ServiceCard(
                                  service: _allServices[index],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceDetailPage(
                                        service: _allServices[index],
                                      ),
                                    ),
                                  ),
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}

// ── Chip untuk filter aktif ──
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0A0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}