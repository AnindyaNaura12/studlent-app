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
  String? imagePath;
  List<String> serviceImages;
  PackageModel basicPackage;
  PackageModel standardPackage; // ← TAMBAH
  PackageModel premiumPackage;  // ← TAMBAH

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
    this.imagePath,
    this.serviceImages = const [],
    PackageModel? basicPackage,
    PackageModel? standardPackage,
    PackageModel? premiumPackage,
    this.name = '',
    this.university = '',
    this.skills = '',
    this.rating = 0.0,
    this.totalReviews = 0,
  })  : basicPackage = basicPackage ?? PackageModel(),
        standardPackage = standardPackage ?? PackageModel(),
        premiumPackage = premiumPackage ?? PackageModel();
}