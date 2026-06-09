class OrderModel {
  final String id;
  final String freelancerName;
  final String freelancerAvatar;
  final String serviceName;
  final String price;
  final String deadline;
  final String status;
  final String note;
  final double amount;
  final double adminFee;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.serviceName,
    required this.price,
    required this.deadline,
    required this.status,
    this.note = '',
    this.amount = 0,
    this.adminFee = 2500,
    this.paymentStatus = 'pending',
    this.paymentMethod = '-',
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final freelancer = json['freelancer'] ?? {};
    final service = json['service'] ?? {};
    final payment = (json['payment'] is List)
        ? (json['payment'] as List).isNotEmpty
              ? json['payment'][0]
              : {}
        : json['payment'] ?? {};

    final double amount = (payment['amount'] as num?)?.toDouble() ?? 0;
    final double adminFee = (payment['admin_fee'] as num?)?.toDouble() ?? 2500;

    final String paymentStatus = payment['status']?.toString() ?? 'pending';
    final String paymentMethod = payment['metode']?.toString() ?? '-';

    return OrderModel(
      id: json['id_order']?.toString() ?? '',
      freelancerName: freelancer['nama']?.toString() ?? 'Unknown Freelancer',
      freelancerAvatar: freelancer['foto']?.toString() ?? '',
      serviceName:
          service['judul']?.toString() ??
          json['detail_pesanan']?.toString() ??
          '-',
      price: amount > 0 ? 'Rp ${_fmt(amount)}' : '-',
      deadline: _formatDate(json['deadline']?.toString()),
      status: json['status']?.toString() ?? 'menunggu_pembayaran',
      note: json['catatan']?.toString() ?? '',
      amount: amount,
      adminFee: adminFee,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
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
