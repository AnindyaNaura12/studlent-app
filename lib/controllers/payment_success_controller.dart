import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSuccessController {
  final supabase = Supabase.instance.client;

  // Fungsi untuk mengambil detail pembayaran dari DB jika dibutuhkan kustomisasi struk
  Future<Map<String, dynamic>?> getPaymentDetail(int idPayment) async {
    try {
      final data = await supabase
          .from('payments')
          .select('*, orders(detail_pesanan, provider_name)')
          .eq('id_payment', idPayment)
          .maybeSingle();
      return data;
    } catch (e) {
      print("Error fetching payment success details: $e");
      return null;
    }
  }

  // Tempat naruh integrasi API Payment Gateway kamu nanti untuk cek status terakhir
  Future<bool> checkGatewayStatus(String transactionId) async {
    // TODO: Pasang integrasi API Midtrans / Xendit di sini untuk double-check status
    return true; 
  }

  // Fungsi simulasi download invoice/struk jika tombolnya ditekan
  Future<void> downloadInvoice(int idOrder) async {
    // Sediakan logic simpan PDF / cetak invoice di sini nanti
    print("Mendownload invoice untuk Order ID: $idOrder");
  }
}