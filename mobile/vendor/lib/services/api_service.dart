import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Android emulator → localhost:3080
  // For real device: replace with your machine's IP e.g. http://192.168.1.X:3080/api
  static const String baseUrl = 'http://10.0.2.2:3080/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() => _storage.read(key: 'vendor_token');

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── Auth ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // ─── Dashboard ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/vendor/dashboard'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ─── Store ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getStore() async {
    final res = await http.get(
      Uri.parse('$baseUrl/vendor/store'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateStore(
      Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vendor/store'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ─── Products ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getProducts({String? status}) async {
    final url = status != null
        ? '$baseUrl/vendor/products?status=$status'
        : '$baseUrl/vendor/products';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/products/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteProduct(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getOrders({String? status}) async {
    final url = status != null
        ? '$baseUrl/vendor/orders?status=$status'
        : '$baseUrl/vendor/orders';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vendor/orders/$orderId/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(res.body);
  }

  // ─── Notifications ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getNotifications() async {
    final res = await http.get(
      Uri.parse('$baseUrl/vendor/notifications'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> markNotificationRead(String id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vendor/notifications/$id/read'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ─── Categories ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCategories() async {
    final res = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: await _headers(auth: false),
    );
    return jsonDecode(res.body);
  }
}
