import 'dart:async'; // ← TAMBAH ini
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/controllers/my_services_controller.dart';
import '/controllers/home_controller.dart';
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

  final _homeController = HomeController();
  final _servicesController = MyServicesController();
  final _supabase = Supabase.instance.client;

  // ── TAMBAH: deklarasi subscription ──────────────────────
  late final StreamSubscription<AuthState> _authSubscription;

  String _greeting = 'People';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();

    // ← TAMBAH: listener otomatis update greeting saat login/logout
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      _loadUserName();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // ← PENTING: cegah memory leak
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      setState(() {
        _isLoggedIn = false;
        _greeting = 'People';
      });
      return;
    }

    setState(() => _isLoggedIn = true);

    try {
      final email = _supabase.auth.currentUser?.email;
      if (email == null) return;

      final data = await _supabase
          .from('users')
          .select('nama')
          .eq('email', email)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          final fullName = data['nama'] as String? ?? 'Student';
          _greeting = fullName.split(' ').first;
        });
      }
    } catch (_) {
      setState(() => _greeting = 'People');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final services = _servicesController.services;

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
              Text(
                "Hi, $_greeting 👋",
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

              // ── SEARCH ──
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

              // ── POPULAR ──
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
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(
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
              ),

              SizedBox(height: s(20)),
            ],
          ),
        ),
      ),
    );
  }
}
