import '../models/services_model.dart';

class MyServicesController {
  List<ServiceModel> services = [
    ServiceModel(
      id: '1',
      title: 'App Design - StuddyBuddy',
      category: 'Graphic Design',
      description: 'Modern UI for study group organization',
      imagePath: 'assets/images/freelancers/freelancer_1.png',
      serviceImages: [],
      basicPackage: PackageModel(
        price: 'Rp. 180.000',
        deliveryTime: '3 days',
        shortDescription: '2 Modern Concepts + Vector Files + Favicon',
      ),
      name: 'Nafila Zahra',
      university: 'Universitas Brawijaya',
      skills: 'Figma, Adobe XD, Prototyping',
      rating: 4.8,
      totalReviews: 24,
    ),
    ServiceModel(
      id: '2',
      title: 'Web Design - Organization',
      category: 'Website Development',
      description: 'What You Get...',
      imagePath: 'assets/images/freelancers/freelancer_1.png',
      serviceImages: [],
      basicPackage: PackageModel(
        price: 'Rp. 180.000',
        deliveryTime: '3 days',
        shortDescription: '2 Modern Concepts + Vector Files + Favicon',
      ),
      name: 'Nafila Zahra',
      university: 'Universitas Brawijaya',
      skills: 'HTML, CSS, Figma',
      rating: 4.5,
      totalReviews: 18,
    ),
  ];

  final List<String> categories = [
    'Website Development',
    'Graphic Design',
    'Photography',
    'Video Editing',
    'Image Editing',
    'Writing & Translation',
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

  void deleteService(String id, void Function() refresh) {
    services.removeWhere((s) => s.id == id);
    refresh();
  }
}
