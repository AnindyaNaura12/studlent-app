class Booking {
  final int id;            
  final int idClient;      
  final int idFreelancer;  
  final int freelancerId;
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
    required this.idClient,
    required this.idFreelancer,
    required this.freelancerId,
    required this.serviceName,
    required this.providerName,
    required this.total,
    required this.orderDate,
    required this.deadline,
    required this.status,
    required this.image,
    required this.note,
  });

  String get statusLabel {
    switch (status) {
      case 'selesai':        return 'Done';
      case 'diproses':
      case 'hasil_dikirim': return 'In Progress';
      case 'revisi':         return 'Revision';
      case 'menunggu_pembayaran':
      case 'paid':           return 'Pending';
      case 'dibatalkan':     return 'Cancelled';
      default:               return status;
    }
  }

  bool get isDone => status == 'selesai';
}