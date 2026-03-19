import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Android emulator → 10.0.2.2 maps to host localhost
  // For real device: replace with your machine's IP e.g. http://192.168.1.X:3080/api
  static const String _baseUrl = 'http://10.0.2.2:3080/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept-Language': 'fr',
    };
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$_baseUrl$path'), headers: headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final headers = await _headers();
    final response = await http.delete(Uri.parse('$_baseUrl$path'), headers: headers);
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      message: body['message'] ?? 'Une erreur est survenue',
      statusCode: response.statusCode,
    );
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return post('/auth/login', {'email': email, 'password': password}, auth: false);
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return post('/auth/register', data, auth: false);
  }

  static Future<Map<String, dynamic>> getMe() async {
    return get('/auth/me');
  }

  // Stores
  static Future<Map<String, dynamic>> getStores({String? type, String? search, String? district}) async {
    final params = <String, String>{};
    if (type != null) params['type'] = type;
    if (search != null) params['search'] = search;
    if (district != null) params['district'] = district;
    final uri = Uri.parse('$_baseUrl/stores').replace(queryParameters: params.isNotEmpty ? params : null);
    final headers = await _headers();
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getStore(String id) async {
    return get('/stores/$id');
  }

  // Products
  static Future<Map<String, dynamic>> getProducts({String? storeId, String? categoryId}) async {
    final params = <String, String>{};
    if (storeId != null) params['storeId'] = storeId;
    if (categoryId != null) params['categoryId'] = categoryId;
    final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: params.isNotEmpty ? params : null);
    final headers = await _headers();
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Orders
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    return post('/orders', data);
  }

  static Future<Map<String, dynamic>> getOrders() async {
    return get('/orders');
  }

  static Future<Map<String, dynamic>> getOrder(String id) async {
    return get('/orders/$id');
  }

  // Categories
  static Future<Map<String, dynamic>> getCategories({String? storeType}) async {
    final query = storeType != null ? '?storeType=$storeType' : '';
    return get('/categories$query');
  }

  // User
  static Future<Map<String, dynamic>> getProfile() async {
    return get('/users/profile');
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return patch('/users/profile', data);
  }

  // Addresses
  static Future<Map<String, dynamic>> getAddresses() async {
    return get('/users/addresses');
  }

  static Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) async {
    return post('/users/addresses', data);
  }

  static Future<Map<String, dynamic>> deleteAddress(String id) async {
    return delete('/users/addresses/$id');
  }

  // Notifications (customer)
  static Future<Map<String, dynamic>> getNotifications() async {
    return get('/notifications');
  }

  static Future<void> markNotificationRead(String id) async {
    await patch('/notifications/$id', {'isRead': true});
  }

  static Future<void> markAllNotificationsRead() async {
    await patch('/notifications', {'isRead': true});
  }

  // Reviews
  static Future<Map<String, dynamic>> getStoreReviews(String storeId) async {
    return get('/reviews?storeId=$storeId');
  }

  static Future<Map<String, dynamic>> submitReview(Map<String, dynamic> data) async {
    return post('/reviews', data);
  }

  // Favorites
  static Future<Map<String, dynamic>> getFavorites() async {
    return get('/users/favorites');
  }

  static Future<Map<String, dynamic>> toggleFavorite(String storeId) async {
    return post('/users/favorites/toggle', {'storeId': storeId});
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
