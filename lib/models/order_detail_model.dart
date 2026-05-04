class OrderDetailModel {
  final String serviceTitle;
  final String deliveryTime;
  final String category;
  final String university;
  final String freelancerName;
  final String freelancerAvatar;
  final double rating;
  final List<String> includes;
  final double selectedPackagePrice;
  final double adminFee;
  final String imagePath;

  OrderDetailModel({
    required this.serviceTitle,
    required this.deliveryTime,
    required this.category,
    required this.university,
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.rating,
    required this.includes,
    required this.selectedPackagePrice,
    required this.adminFee,
    required this.imagePath,
  });

  double get total => selectedPackagePrice + adminFee;
}
