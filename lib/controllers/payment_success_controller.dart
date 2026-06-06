import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentSuccessController {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getPaymentDetail(int idPayment) async {
    try {
      final data = await supabase
          .from('payments')
          // ← FIX: hapus provider_name — kolom tidak ada di schema
          .select('*, orders(detail_pesanan, catatan)')
          .eq('id_payment', idPayment)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error fetching payment success details: $e');
      return null;
    }
  }

  Future<bool> checkGatewayStatus(String transactionId) async {
    return true;
  }

  Future<void> downloadInvoice(int idOrder) async {
    debugPrint('Mendownload invoice untuk Order ID: $idOrder');
  }
}