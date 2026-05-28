import 'dart:math';
import 'package:flutter/material.dart';
import '/controllers/my_services_controller.dart';
import '/models/services_model.dart';
import '../widgets/freelancer_card_horizontal.dart';
import '../pages/service_detail_page.dart';

class AllServicesPage extends StatefulWidget {
  const AllServicesPage({super.key});

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage> {
  final _servicesController = MyServicesController();
  List<ServiceModel> _allRandomServices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllServices();
  }

  Future<void> _loadAllServices() async {
    setState(() => _loading = true);

    await _servicesController.fetchServices();

    final services = List<ServiceModel>.from(_servicesController.services);
    services.shuffle(Random());

    if (!mounted) return;

    setState(() {
      _allRandomServices = services;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EE),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'All Services',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allRandomServices.isEmpty
          ? const Center(
              child: Text(
                'Belum ada service tersedia',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: s(20), vertical: s(10)),
              itemCount: _allRandomServices.length,
              itemBuilder: (context, index) {
                return FreelancerCardHorizontal(
                  service: _allRandomServices[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailPage(
                          service: _allRandomServices[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
