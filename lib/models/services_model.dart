class PackageModel {
  final int? id; // ← TAMBAH: id_package dari DB
  String price;
  String deliveryTime;
  String shortDescription;
  String name; // ← TAMBAH: 'basic' / 'standard' / 'premium'

  PackageModel({
    this.id,
    this.price = '',
    this.deliveryTime = '',
    this.shortDescription = '',
    this.name = 'basic',
  });

  // ── fromJson dari tabel service_packages ──────────────────
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id_package'] as int?,
      name: json['nama'] ?? 'basic',
      price: 'Rp ${_formatPrice((json['harga'] ?? 0).toDouble())}',
      deliveryTime: '${json['delivery_time'] ?? 3} days',
      shortDescription: json['deskripsi'] ?? '',
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
      if (count > 0 && count % 3 == 0) result.write('.');
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

  final String name;
  final String university;
  final String skills;
  final double rating;
  final int totalReviews;

  // ── TAMBAH: field untuk koneksi ke DB ─────────────────────
  final int? freelancerId; // ← id_freelancer di tabel services
  int? packageId; // ← id_package yang dipilih user (basic/std/premium)

  ServiceModel({
    required this.id,
    required this.title,
    this.category = '',
    this.description = '',
    this.imagePath,
    this.serviceImages = const [],
    PackageModel? basicPackage,
    // Default values untuk data tambahan
    this.name = '',
    this.university = '',
    this.skills = '',
    this.rating = 0.0,
    this.totalReviews = 0,
    this.freelancerId,
  }) : basicPackage = basicPackage ?? PackageModel();

  // ── fromJson dari tabel service_detail di Supabase ────────
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id_service']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'],
      serviceImages: json['service_images'] != null
          ? List<String>.from(json['service_images'])
          : [],
      basicPackage: PackageModel(
        price: json['basic_price'] ?? 'Rp 0',
        deliveryTime: '${json['basic_delivery_time'] ?? 3} days',
        shortDescription: json['basic_description'] ?? '',
      ),
      name: json['freelancer_name'] ?? '',
      university: json['university'] ?? '',
      skills: json['skills'] ?? '',
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      freelancerId: json['id_freelancer'] as int?,
    );
  }

  // PERBAIKAN: Mengakses price melalui basicPackage
  bool get isValid => basicPackage.price.isNotEmpty && rating > 0;
}
