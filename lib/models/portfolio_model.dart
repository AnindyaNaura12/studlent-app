class PortfolioModel {
  final int? id;
  final String title;
  final String description;
  final String jobdesk; // DIUBAH: dari category ke jobdesk
  final String? thumbnailUrl;
  final List<String> fileUrls;

  PortfolioModel({
    this.id,
    required this.title,
    required this.description,
    required this.jobdesk,
    this.thumbnailUrl,
    this.fileUrls = const [],
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id_portfolio'],
      title: json['judul'] ?? '',
      description: json['deskripsi'] ?? '',
      jobdesk: json['jobdesk'] ?? json['category'] ?? '', // DITAMBAH: fallback ke category
      thumbnailUrl: json['thumbnail_url'],
      fileUrls: json['file_urls'] != null
          ? List<String>.from(json['file_urls'])
          : [],
    );
  }
}