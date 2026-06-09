class Booking {
  final int id;
  final int freelancerId;
  final int orderId;
  final int clientId;
  final int serviceId;
  final String serviceName;
  final String providerName;
  final String total;
  final String orderDate;
  final String deadline;
  final String status;
  final String image;
  final String note;

  Booking({
    required this.id,
    required this.freelancerId,
    required this.orderId,
    required this.clientId,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.total,
    required this.orderDate,
    required this.deadline,
    required this.status,
    required this.image,
    required this.note,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final freelancer = json['freelancer'] ?? {};
    final service = json['service'] ?? {};
    final payment = (json['payment'] is List)
        ? (json['payment'] as List).isNotEmpty
              ? (json['payment'] as List).first
              : {}
        : json['payment'] ?? {};

    final double amount = (payment['amount'] as num?)?.toDouble() ?? 0;

    return Booking(
      id: json['id'] as int? ?? 0,
      freelancerId: json['id_freelancer'] as int? ?? 0,
      orderId: json['id_order'] as int? ?? 0,
      clientId: json['id_client'] as int? ?? 0,
      serviceId: json['id_service'] as int? ?? 0,
      serviceName:
          service['judul']?.toString() ??
          json['detail_pesanan']?.toString() ??
          '-',
      providerName: freelancer['nama']?.toString() ?? 'Unknown Freelancer',
      total: _fmt(amount),
      orderDate: _formatDate(json['created_at']?.toString()),
      deadline: _formatDate(json['deadline']?.toString()),
      status: json['status']?.toString() ?? 'menunggu_pembayaran',
      image: freelancer['foto']?.toString() ?? '',
      note: json['catatan']?.toString() ?? '',
    );
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
