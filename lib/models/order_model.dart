class OrderModel {
  final String id;
  final String freelancerName;
  final String freelancerAvatar;
  final String serviceName;
  final String price;
  final String deadline;
  final String status;
  final String note;
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
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final freelancerData = json['freelancers'] ?? {}; 
    final serviceData = json['services'] ?? {};

    return OrderModel(
      id: json['id_order']?.toString() ?? '',
      freelancerName: freelancerData['name'] ?? 'Unknown Freelancer',
      freelancerAvatar: freelancerData['avatar_url'] ?? 'assets/images/freelancers/default.png', 
      serviceName: serviceData['name'] ?? serviceData['title'] ?? 'Unknown Service',
      price: serviceData['price'] != null ? 'Rp. ${serviceData['price']}' : 'Rp. 0', 
      deadline: _formatDate(json['deadline']),
      status: json['status'] ?? 'menunggu_pembayaran',
      note: json['detail_pesanan'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
