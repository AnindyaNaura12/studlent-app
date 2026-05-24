class ServiceCategory {
  final int id;
  final String name;

  ServiceCategory({required this.id, required this.name});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: (json['id_category'] as num).toInt(),
      name: json['nama']?.toString() ?? '',
    );
  }
}
