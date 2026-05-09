class PaymentModel {
  final int idPayment;
  final int idOrder;
  final double amount;
  final String status;
  final String escrowStatus;
  final String paymentUrl;
  final String gatewayTrxId;

  PaymentModel({
    required this.idPayment,
    required this.idOrder,
    required this.amount,
    required this.status,
    required this.escrowStatus,
    required this.paymentUrl,
    required this.gatewayTrxId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      idPayment: json['id_payment'],
      idOrder: json['id_order'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      escrowStatus: json['escrow_status'],
      paymentUrl: json['payment_url'] ?? '',
      gatewayTrxId: json['gateway_trx_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_payment": idPayment,
      "id_order": idOrder,
      "amount": amount,
      "status": status,
      "escrow_status": escrowStatus,
      "payment_url": paymentUrl,
      "gateway_trx_id": gatewayTrxId,
    };
  }
}