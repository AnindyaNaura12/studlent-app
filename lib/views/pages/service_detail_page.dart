// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_back_button.dart';
import '../../models/services_model.dart';
import 'detail_profile_freelancer.dart';
import '../../controllers/services_controller.dart';
import 'contact_freelancer_page.dart';
import 'detail_order_page.dart';

class ServiceDetailPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  int selectedTab = 0;

  final ServicesController controller = ServicesController();
  final _supabase = Supabase.instance.client;

  List<PackageModel> _packages = [];
  String? _freelancerPhotoUrl;
  bool _loadingPackages = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPackages(), _loadFreelancerPhoto()]);
  }

  Future<void> _loadPackages() async {
    try {
      final idService = int.tryParse(widget.service.id);
      if (idService == null) {
        setState(() => _loadingPackages = false);
        return;
      }

      final data = await _supabase
          .from('service_packages')
          .select()
          .eq('id_service', idService)
          .order('id_package', ascending: true);

      final packages = (data as List)
          .map((e) => PackageModel.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          _packages = packages;
          _loadingPackages = false;
        });
      }
    } catch (e) {
      debugPrint('loadPackages error: $e');
      if (mounted) setState(() => _loadingPackages = false);
    }
  }

  Future<void> _loadFreelancerPhoto() async {
    try {
      final freelancerId = widget.service.freelancerId;
      if (freelancerId == null) return;

      // Coba ambil dari freelancer_profiles dulu
      final fpData = await _supabase
          .from('freelancer_profiles')
          .select('foto_freelancer')
          .eq('id_user', freelancerId)
          .maybeSingle();

      String? photoUrl;

      if (fpData != null &&
          fpData['foto_freelancer'] != null &&
          (fpData['foto_freelancer'] as String).isNotEmpty) {
        photoUrl = fpData['foto_freelancer'] as String;
      } else {
        // Fallback ke tabel users
        final userData = await _supabase
            .from('users')
            .select('foto')
            .eq('id_user', freelancerId)
            .maybeSingle();

        if (userData != null && userData['foto'] != null) {
          photoUrl = userData['foto'] as String;
        }
      }

      if (mounted) setState(() => _freelancerPhotoUrl = photoUrl);
    } catch (e) {
      debugPrint('loadFreelancerPhoto error: $e');
    }
  }

  String get _currentTitle {
    if (_packages.isEmpty) return controller.getPackageTitle(selectedTab);
    if (selectedTab < _packages.length) {
      final n = _packages[selectedTab].name;
      return '${n[0].toUpperCase()}${n.substring(1)} Package';
    }
    return '';
  }

  String get _currentPrice {
    if (_packages.isEmpty)
      return controller.getPackagePrice(selectedTab, widget.service);
    if (selectedTab < _packages.length) return _packages[selectedTab].price;
    return '';
  }

  String get _currentDesc {
    if (_packages.isEmpty)
      return controller.getPackageDescription(selectedTab, widget.service);
    if (selectedTab < _packages.length)
      return _packages[selectedTab].shortDescription;
    return '';
  }

  String get _currentDelivery {
    if (_packages.isEmpty) return widget.service.basicPackage.deliveryTime;
    if (selectedTab < _packages.length)
      return _packages[selectedTab].deliveryTime;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final service = widget.service;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(s(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomBackButton(
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          const Text(
                            'Detail Service',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title & Rating
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: s(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: s(6)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: s(4)),
                        Text(
                          "${service.rating} (${service.totalReviews})",
                          style: TextStyle(fontSize: s(12)),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: s(10),
                            vertical: s(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            service.category,
                            style: TextStyle(fontSize: s(10)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: s(16)),

                    // Gambar Service (thumbnail dari storage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(s(16)),
                      child: _buildServiceImage(service, s),
                    ),

                    SizedBox(height: s(16)),

                    // Profil Freelancer — pakai _freelancerPhotoUrl bukan service.imagePath
                    Row(
                      children: [
                        CircleAvatar(
                          radius: s(20),
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              _freelancerPhotoUrl != null &&
                                  _freelancerPhotoUrl!.startsWith('http')
                              ? NetworkImage(_freelancerPhotoUrl!)
                              : null,
                          child: _freelancerPhotoUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: s(20),
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        SizedBox(width: s(10)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: s(13),
                              ),
                            ),
                            SizedBox(height: s(2)),
                            GestureDetector(
                              onTap: () =>
                                  controller.goToProfile(context, service),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: s(10),
                                  vertical: s(4),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFA726),
                                  borderRadius: BorderRadius.circular(s(20)),
                                ),
                                child: Text(
                                  "View Profile",
                                  style: TextStyle(
                                    fontSize: s(10),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: s(20)),

                    // Package Pricing — dari DB
                    Text(
                      "Package Pricing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(14),
                      ),
                    ),
                    SizedBox(height: s(10)),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(s(20)),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: _loadingPackages
                            ? [
                                _tab("Basic", 0, s),
                                _tab("Standard", 1, s),
                                _tab("Premium", 2, s),
                              ]
                            : _packages.isNotEmpty
                            ? _packages.asMap().entries.map((e) {
                                final name = e.value.name;
                                return _tab(
                                  '${name[0].toUpperCase()}${name.substring(1)}',
                                  e.key,
                                  s,
                                );
                              }).toList()
                            : [
                                _tab("Basic", 0, s),
                                _tab("Standard", 1, s),
                                _tab("Premium", 2, s),
                              ],
                      ),
                    ),

                    SizedBox(height: s(12)),

                    _loadingPackages
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(s(12)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEED9B7),
                              borderRadius: BorderRadius.circular(s(14)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: s(12),
                                  ),
                                ),
                                SizedBox(height: s(4)),
                                Text(
                                  _currentPrice,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: s(14),
                                  ),
                                ),
                                SizedBox(height: s(4)),
                                Text(
                                  _currentDesc,
                                  style: TextStyle(fontSize: s(11)),
                                ),
                                Text(
                                  "Delivery: $_currentDelivery",
                                  style: TextStyle(fontSize: s(11)),
                                ),
                              ],
                            ),
                          ),

                    SizedBox(height: s(20)),

                    // About
                    Text(
                      "About This Service",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(14),
                      ),
                    ),
                    SizedBox(height: s(8)),
                    Text(
                      service.description,
                      style: TextStyle(fontSize: s(12), color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: EdgeInsets.all(s(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: s(10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    _currentPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: s(16),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactFreelancerPage(
                            freelancerId: service.freelancerId ?? 0,
                            freelancerName: service.name,
                            image: _freelancerPhotoUrl ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Text("Chat Seller"),
                  ),
                  SizedBox(width: s(10)),
                  ElevatedButton(
                    onPressed: () {
                      final PackageModel? selected =
                          _packages.isNotEmpty && selectedTab < _packages.length
                          ? _packages[selectedTab]
                          : null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailOrderPage(
                            service: service,
                            selectedPackage: selected,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Order Now",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceImage(ServiceModel service, double Function(double) s) {
    final imgPath = service.imagePath;
    if (imgPath != null && imgPath.startsWith('http')) {
      return Image.network(
        imgPath,
        width: double.infinity,
        height: s(180),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(s),
      );
    }
    if (service.serviceImages.isNotEmpty) {
      final first = service.serviceImages.first;
      if (first.startsWith('http')) {
        return Image.network(
          first,
          width: double.infinity,
          height: s(180),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderImage(s),
        );
      }
    }
    return _placeholderImage(s);
  }

  Widget _placeholderImage(double Function(double) s) {
    return Container(
      width: double.infinity,
      height: s(180),
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, color: Colors.grey, size: 48),
    );
  }

  Widget _tab(String text, int index, double Function(double) s) {
    final isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: s(10)),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFA726) : Colors.transparent,
            borderRadius: BorderRadius.circular(s(20)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
