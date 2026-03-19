import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DeliveryApiService {
  // Android emulator → 10.0.2.2 maps to host localhost
  // For real device: replace with your machine's IP e.g. http://192.168.1.X:3080/api
  static const String _baseUrl = 'http://10.0.2.2:3080/api';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'delivery_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['message'] ?? 'Erreur serveur');
  }

  static Future<Map<String, dynamic>> getAssignedOrders() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$_baseUrl/orders?status=READY'), headers: headers);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getMyDeliveries() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$_baseUrl/orders'), headers: headers);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getOrder(String id) async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$_baseUrl/orders/$id'), headers: headers);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final headers = await _headers();
    final res = await http.patch(
      Uri.parse('$_baseUrl/orders/$id/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    return _parse(res);
  }
}
