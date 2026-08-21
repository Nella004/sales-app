import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://10.0.2.2:3000/api';

  static Future<List<dynamic>> getVendors() async {
    final res = await http.get(Uri.parse('$baseUrl/vendors'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> submitVendor(String name, String info) async {
    final res = await http.post(
      Uri.parse('$baseUrl/vendors'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'business_info': info}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyVendor(int vendorId, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vendors/$vendorId/verify'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getBalance(int vendorId) async {
    final res = await http.get(Uri.parse('$baseUrl/vendors/$vendorId/balance'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> sendMoney(int vendorId, double amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transfers/send'),
      headers: { 'Content-Type': 'application/json'},
      // 🚀 Fixed: Changed 'vendorId' to 'vendor_id' to match req.body in routes/ledger.js
      body: jsonEncode({'vendor_id': vendorId, 'amount': amount}), 
    );
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'Send failed');
    }
    return data;
  }

  static Future<Map<String, dynamic>> getVendorBankBalance (int vendorId) async {
    final res = await http.get(Uri.parse('$baseUrl/vendors/$vendorId/bank-balance'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getBuyerBankBalance() async {
    final res = await http.get(Uri.parse('$baseUrl/accounts/buyer'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getTransactions(int vendorId) async {
    final res = await http.get(Uri.parse('$baseUrl/vendors/$vendorId/transactions'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> reconcile() async {
    final res = await http.get(Uri.parse('$baseUrl/reconcile'));
    return jsonDecode(res.body);
  }
}
