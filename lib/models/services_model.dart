class PackageModel {
  String price;
  String deliveryTime;
  String shortDescription;

  PackageModel({
    this.price = '',
    this.deliveryTime = '',
    this.shortDescription = '',
  });
}

class ServiceModel {
  final String id;

  String title;
  String category;
  String description;

  // 🔥 FIX: non-nullable biar aman di UI
  String imagePath;

  List<String> serviceImages;

  PackageModel basicPackage;

  // UI fields
  final String name;
  final String university;
  final String skills;
  final double rating;
  final int totalReviews;

  ServiceModel({
    required this.id,
    required this.title,
    this.category = '',
    this.description = '',

    // 🔥 FIX utama
    this.imagePath = '',

    this.serviceImages = const [],

    PackageModel? basicPackage,

    this.name = '',
    this.university = '',
    this.skills = '',
    this.rating = 0.0,
    this.totalReviews = 0,
  }) : basicPackage = basicPackage ?? PackageModel();

  // 🔥 supaya UI tetap bisa pakai service.price
  String get price => basicPackage.price;

  bool get isValid => basicPackage.price.isNotEmpty && rating > 0;
}