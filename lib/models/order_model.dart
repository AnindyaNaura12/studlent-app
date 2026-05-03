class OrderModel {
  final String id;
  final String freelancerName;
  final String freelancerAvatar;
  final String serviceName;
  final String price;
  final String deadline;
  final String status;
  final String note;

  OrderModel({
    required this.id,
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.serviceName,
    required this.price,
    required this.deadline,
    required this.status,
    this.note = '',
  });
}
