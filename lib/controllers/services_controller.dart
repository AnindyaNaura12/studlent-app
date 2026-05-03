import 'package:flutter/material.dart';
import '../views/pages/detail_profile_freelancer.dart';
import '../models/services_model.dart';
import '../views/pages/service_detail_page.dart';

class MyServicesController {
  List<ServiceModel> services = [
    ServiceModel(
      id: '1',
      title: 'App Design- StuddyBuddy',
      category: 'Design',
      description: 'Modern UI for study group organization',
      imagePath: null,
      serviceImages: [],
      basicPackage: PackageModel(
        price: 'Rp. 180.000',
        deliveryTime: '3 days',
        shortDescription: '2 Modern Concepts + Vector Files + Favicon',
      ),
    ),
    ServiceModel(
      id: '2',
      title: 'Web Design - Organization',
      category: 'Design Web',
      description:
          'What You Get:\n• Custom shopify store design / Shopify Redesign & complete ecommerce website development\n• Professional dropshipping website with product optimization\n• Premium theme customization & essential apps',
      imagePath: 'assets/images/portfolio_sample.png',
      serviceImages: [],
      basicPackage: PackageModel(
        price: 'Rp. 180.000',
        deliveryTime: '3 days',
        shortDescription: '2 Modern Concepts + Vector Files + Favicon',
      ),
    ),
  ];

  List<String> getCategories() {
    return categories;
  }

  // Getter untuk deliveryTimes
  List<String> getDeliveryTimes() {
    return deliveryTimes;
  }

  final List<String> categories = [
    'Design',
    'Design Web',
    'Mobile Development',
    'Write & Translation',
    'Digital Marketing',
    'Video & Animation',
  ];

  final List<String> deliveryTimes = [
    '1 day',
    '2 days',
    '3 days',
    '5 days',
    '7 days',
    '14 days',
    '30 days',
  ];

  void deleteService(String id, void Function() refresh) {
    services.removeWhere((s) => s.id == id);
    refresh();
  }

  void addService(ServiceModel service, void Function() refresh) {
    services.add(service);
    refresh();
  }

  void updateService(ServiceModel updated, void Function() refresh) {
    final index = services.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      services[index] = updated;
      refresh();
    }
  }

  String getPackageTitle(
    int selectedTab,
  ) {
    switch (selectedTab) {
      case 0:
        return "Basic Package";

      case 1:
        return "Standard Package";

      case 2:
        return "Premium Package";

      default:
        return "";
    }
  }

  String getPackageDescription(
    int selectedTab,
    ServiceModel service,
  ) {
    switch (selectedTab) {
      case 0:
        return service.basicPackage.shortDescription;

      case 1:
        return "2 Concepts + Vector Files + Favicon";

      case 2:
        return "3 Concepts + All Files + Source + Priority";

      default:
        return "";
    }
  }

  String getPackagePrice(
    int selectedTab,
    ServiceModel service,
  ) {
    switch (selectedTab) {
      case 0:
        return service.basicPackage.price;

      case 1:
        return service.basicPackage.price;

      case 2:
        return "Rp 500.000";

      default:
        return "";
    }
  }

  void goToProfile(
    BuildContext context,
    ServiceModel service,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProfileFreelancer(
          service: service,
        ),
      ),
    );
  }

  void goToServiceDetail(
    BuildContext context,
    ServiceModel service,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailPage(
          service: service,
        ),
      ),
    );
  }

}
