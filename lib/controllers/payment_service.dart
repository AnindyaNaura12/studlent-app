import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const baseUrl = "http://10.0.2.2:8000/api"; 
  // emulator localhost Laravel

  static Future<Map<String, dynamic>> getPayment(
      int orderId, String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/pay/$orderId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load payment");
    }
  }
}