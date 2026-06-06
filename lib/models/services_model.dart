class PackageModel {
  final int? id;
  String price;
  String deliveryTime;
  String shortDescription;
  String name;

  PackageModel({
    this.id,
    this.price = '',
    this.deliveryTime = '',
    this.shortDescription = '',
    this.name = 'basic',
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id_package'] as int?,
      name: json['nama']?.toString() ?? 'basic',
      price: 'Rp ${_formatPrice((json['harga'] ?? 0).toDouble())}',
      deliveryTime: '${json['delivery_time'] ?? 3} days',
      shortDescription: json['deskripsi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_package': id,
    'nama': name,
    'harga':
        double.tryParse(
          price
              .replaceAll('Rp', '')
              .replaceAll('.', '')
              .replaceAll(' ', '')
              .trim(),
        ) ??
        0,
    'delivery_time':
        int.tryParse(deliveryTime.replaceAll(RegExp(r'[^0-9]'), '')) ?? 3,
    'deskripsi': shortDescription,
  };

  static String _formatPrice(double price) {
    final formatted = price.toInt().toString();
    final result = StringBuffer();
    int count = 0;

    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result.write('.');
      }
      result.write(formatted[i]);
      count++;
    }

    return result.toString().split('').reversed.join();
  }
}

class ServiceModel {
  final String id;
  String title;
  String category;
  String description;
  String? imagePath;
  List<String> serviceImages;

  PackageModel basicPackage;
  PackageModel? standardPackage;
  PackageModel? premiumPackage;

  final String name;
  final String university;
  final String skills;
  final double rating;
  final int totalOrder;
  final String? freelancerName;

  final int? freelancerId;
  int? packageId;

  ServiceModel({
    required this.id,
    required this.title,
    this.category = '',
    this.description = '',
    this.imagePath,
    this.serviceImages = const [],
    PackageModel? basicPackage,
    this.standardPackage,
    this.premiumPackage,
    this.name = '',
    this.university = '',
    this.skills = '',
    this.rating = 0.0,
    this.totalOrder = 0,
    this.freelancerId,
    this.freelancerName,
  }) : basicPackage = basicPackage ?? PackageModel();

  static String? _cleanImage(String? url) {
    if (url == null || url.isEmpty) return null;

    if (url.startsWith('assets/http')) {
      return url.replaceFirst('assets/', '');
    }

    return url;
  }

  static PackageModel? _buildOptionalPackage({
    required String name,
    required dynamic id,
    required dynamic price,
    required dynamic deliveryTime,
    required dynamic shortDescription,
  }) {
    final hasAnyValue =
        id != null ||
        price != null ||
        deliveryTime != null ||
        (shortDescription?.toString().isNotEmpty ?? false);

    if (!hasAnyValue) return null;

    return PackageModel(
      id: id as int?,
      name: name,
      price: 'Rp ${PackageModel._formatPrice((price ?? 0).toDouble())}',
      deliveryTime: '${deliveryTime ?? 3} days',
      shortDescription: shortDescription?.toString() ?? '',
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id_service']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imagePath: _cleanImage(json['image_path']?.toString()),
      serviceImages: json['service_images'] != null
          ? List<String>.from(json['service_images'])
                .map((e) => _cleanImage(e.toString()) ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
          : [],
      basicPackage: PackageModel(
        id: json['basic_package_id'] as int?,
        name: 'basic',
        price:
            'Rp ${PackageModel._formatPrice((json['basic_price'] ?? 0).toDouble())}',
        deliveryTime: '${json['basic_delivery_time'] ?? 3} days',
        shortDescription: json['basic_description']?.toString() ?? '',
      ),
      standardPackage: _buildOptionalPackage(
        name: 'standard',
        id: json['standard_package_id'],
        price: json['standard_price'],
        deliveryTime: json['standard_delivery_time'],
        shortDescription: json['standard_description'],
      ),
      premiumPackage: _buildOptionalPackage(
        name: 'premium',
        id: json['premium_package_id'],
        price: json['premium_price'],
        deliveryTime: json['premium_delivery_time'],
        shortDescription: json['premium_description'],
      ),
      name: json['freelancer_name']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      skills: json['skills']?.toString() ?? '',
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      totalOrder: json['total_order'] as int? ?? 0,
      freelancerId: json['id_freelancer'] as int?,
      freelancerName: json['freelancer_name']?.toString(),
    );
  }

  bool get isValid => basicPackage.price.isNotEmpty && rating >= 0;
}
