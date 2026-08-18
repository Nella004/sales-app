import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://10.0.0.166:3000/api';

  static Future<List<dynamic>> getVendors() async {
    final res = await http.get(Uri.parse('$baseUrl/vendors'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> submitVendor(String name, String info, String idNum) async {
    final res = await http.post(
      Uri.parse('$baseUrl/vendors'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'business_info': info, 'id_number': idNum}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getBalance(int vendorId) async {
    final res = await http.get(Uri.parse('$baseUrl/vendors/$vendorId/balance'));
    return jsonDecode(res.body);
  }
}