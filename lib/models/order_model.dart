import 'package:supabase_flutter/supabase_flutter.dart';

class OrderModel {
  final String id;
  final int freelancerId;
  final String freelancerName;
  final String freelancerAvatar;
  final String serviceName;
  final String serviceImage;
  final String price;
  final String deadline;
  final String status;
  final String note;
  final double amount;
  final double adminFee;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;
  final String? fileUrl;

  OrderModel({
    required this.id,
    required this.freelancerId,
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.serviceName,
    required this.serviceImage,
    required this.price,
    required this.deadline,
    required this.status,
    this.note = '',
    this.amount = 0,
    this.adminFee = 2500,
    this.paymentStatus = 'pending',
    this.paymentMethod = '-',
    this.createdAt,
    this.fileUrl,
  });

  double get packagePrice => amount;
  double get totalAmount => amount + adminFee;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final freelancerRaw = json['freelancer'];
    final Map<String, dynamic> freelancer = freelancerRaw is Map
        ? Map<String, dynamic>.from(freelancerRaw)
        : <String, dynamic>{};

    final serviceRaw = json['service'];
    final Map<String, dynamic> service = serviceRaw is Map
        ? Map<String, dynamic>.from(serviceRaw)
        : <String, dynamic>{};

    final paymentRaw = json['payment'];
    final Map<String, dynamic> payment = paymentRaw is List
        ? (paymentRaw.isNotEmpty && paymentRaw.first is Map
              ? Map<String, dynamic>.from(paymentRaw.first)
              : <String, dynamic>{})
        : (paymentRaw is Map
              ? Map<String, dynamic>.from(paymentRaw)
              : <String, dynamic>{});

    final serviceImagesRaw = service['service_images'];
    final List<Map<String, dynamic>> serviceImages = serviceImagesRaw is List
        ? serviceImagesRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    String rawImage = '';
    if (serviceImages.isNotEmpty) {
      rawImage = serviceImages.first['image_url']?.toString() ?? '';
    }

    if (rawImage.trim().isEmpty) {
      rawImage = service['thumbnail_url']?.toString() ?? '';
    }

    final double amount = (payment['amount'] as num?)?.toDouble() ?? 0;
    final double adminFee = (payment['admin_fee'] as num?)?.toDouble() ?? 2500;

    return OrderModel(
      id: json['id_order']?.toString() ?? '',
      freelancerId: (json['id_freelancer'] as num?)?.toInt() ?? 0,
      freelancerName: freelancer['nama']?.toString() ?? 'Unknown Freelancer',
      freelancerAvatar: freelancer['foto']?.toString() ?? '',
      serviceName:
          service['judul']?.toString() ??
          json['detail_pesanan']?.toString() ??
          '-',
      serviceImage: _resolveImageUrl(rawImage),
      price: amount > 0 ? 'Rp ${_fmt(amount)}' : '-',
      deadline: _formatDate(json['deadline']?.toString()),
      status:
          json['status']?.toString().trim().toLowerCase() ??
          'menunggu_pembayaran',
      note: json['catatan']?.toString() ?? '',
      amount: amount,
      adminFee: adminFee,
      paymentStatus: payment['status']?.toString() ?? 'pending',
      paymentMethod: payment['metode']?.toString() ?? '-',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      fileUrl: payment['payment_url']?.toString(),
    );
  }

  static String _resolveImageUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    String normalizedPath = value;

    if (normalizedPath.startsWith('service-images/')) {
      normalizedPath = normalizedPath.substring('service-images/'.length);
    }

    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    try {
      return Supabase.instance.client.storage
          .from('service-images')
          .getPublicUrl(normalizedPath);
    } catch (_) {
      return '';
    }
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';

    try {
      final date = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String _fmt(double price) {
    final s = price.toInt().toString();
    final buf = StringBuffer();
    int count = 0;

    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }

    return buf.toString().split('').reversed.join();
  }
}
