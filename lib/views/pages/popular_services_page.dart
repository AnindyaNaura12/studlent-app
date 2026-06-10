import 'package:flutter/material.dart';
import '/controllers/my_services_controller.dart';
import '/controllers/home_controller.dart';
import '/models/services_model.dart';
import '../pages/service_detail_page.dart';
import '../widgets/freelancer_card_horizontal.dart';
import '../../models/category_model.dart';

class PopularServicesPage extends StatefulWidget {
  const PopularServicesPage({super.key});

  @override
  State<PopularServicesPage> createState() => _PopularServicesPageState();
}

class _PopularServicesPageState extends State<PopularServicesPage> {
  final _servicesController = MyServicesController();
  final _homeController = HomeController();

  List<ServiceModel> _allPopularServices = [];
  List<ServiceModel> _filteredPopularServices = [];
  List<CategoryModel> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    await _servicesController.fetchServices();
    final cats = await _homeController.getCategories(); // ← tambah ini
    if (mounted) {
      setState(() {
        _allPopularServices = List<ServiceModel>.from(_servicesController.services);
        _filteredPopularServices = _allPopularServices;
        _categories = cats; // ← tambah ini
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;

      if (category == 'All') {
        _filteredPopularServices = _allPopularServices;
      } else {
        _filteredPopularServices = _allPopularServices
            .where(
              (service) => service.category.toLowerCase().contains(
                category.toLowerCase(),
              ),
            )
            .toList();
      }
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
          'Popular Services',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: s(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: s(10)),

            SizedBox(
              height: s(42),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: s(8)),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCategory == 'All',
                      onSelected: (_) => _filterByCategory('All'),
                      selectedColor: const Color(0xFFFFB74D),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedCategory == 'All'
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ..._categories.map((category) {
                    final isSelected = _selectedCategory == category.title;
                    return Padding(
                      padding: EdgeInsets.only(right: s(8)),
                      child: ChoiceChip(
                        label: Text(category.title),
                        selected: isSelected,
                        onSelected: (_) => _filterByCategory(category.title),
                        selectedColor: const Color(0xFFFFB74D),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            SizedBox(height: s(16)),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB74D)))
                  : _filteredPopularServices.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada popular service pada kategori ini',
                            style: TextStyle(
                              fontSize: s(13),
                              color: Colors.black45,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredPopularServices.length,
                          itemBuilder: (context, index) {
                            return FreelancerCardHorizontal(
                              service: _filteredPopularServices[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailPage(
                                      service: _filteredPopularServices[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
