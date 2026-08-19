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

  static Future<Map<String, dynamic>> verifyVendor(int vendorId, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vendors/$vendorId/verify'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}), //meaning verified or unverified
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getBalance(int vendorId) async {
    final res = await http.get(Uri.parse('$baseUrl/vendors/$vendorId/balance'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> releasefunds(int vendorId, double amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transfers/release'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'vendorId': vendorId, 'amount': amount}), //meaning verified or unverified
    );
    return jsonDecode(res.body);
  }

  //To simulate payment landing in escrow (stand in for processor webhook)
  static Future<Map<String, dynamic>> receivefunds(int vendorId, double amount, String referenceId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/webhooks/payment'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'vendorId': vendorId, 'amount': amount, 'reference_id': referenceId}), //meaning verified or unverified
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> reconcile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/reconcile'),);
    return jsonDecode(res.body);
  }
}