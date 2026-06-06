import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // ← FIX: samakan dengan PaymentWebViewPage
  static const _baseUrl = 'http://10.0.2.2:8000/api';
  // static const _baseUrl = 'http://192.168.0.109:8000/api'; // device fisik

  // ← FIX: endpoint yang benar & public (tidak perlu token)
  static Future<Map<String, dynamic>> getOrderStatus(int orderId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/$orderId/status'),
      headers: {'Accept': 'application/json'}, // ← FIX: hapus Authorization header
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load order status: ${response.statusCode}');
    }
  }
}