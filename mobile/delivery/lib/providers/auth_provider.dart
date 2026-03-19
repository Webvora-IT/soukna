import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DeliveryUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String role;

  DeliveryUser({required this.id, required this.email, required this.name, this.phone, required this.role});

  factory DeliveryUser.fromJson(Map<String, dynamic> json) => DeliveryUser(
    id: json['id'], email: json['email'], name: json['name'],
    phone: json['phone'], role: json['role'] ?? 'DELIVERY',
  );
}

class AuthProvider extends ChangeNotifier {
  DeliveryUser? _user;
  String? _token;
  bool _loading = true;
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://10.0.2.2:3080/api';

  DeliveryUser? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() { _init(); }

  Future<void> _init() async {
    _token = await _storage.read(key: 'delivery_token');
    if (_token != null) {
      try {
        final res = await http.get(
          Uri.parse('$_baseUrl/auth/me'),
          headers: {'Authorization': 'Bearer $_token'},
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final user = DeliveryUser.fromJson(data['data']);
          if (user.role != 'DELIVERY' && user.role != 'ADMIN') {
            throw Exception('Accès réservé aux livreurs');
          }
          _user = user;
        } else {
          _token = null;
          await _storage.delete(key: 'delivery_token');
        }
      } catch (_) {
        _token = null;
        await _storage.delete(key: 'delivery_token');
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur de connexion');
    }
    final user = DeliveryUser.fromJson(data['data']['user']);
    if (user.role != 'DELIVERY' && user.role != 'ADMIN') {
      throw Exception('Accès réservé aux livreurs SOUKNA');
    }
    _token = data['data']['token'];
    _user = user;
    await _storage.write(key: 'delivery_token', value: _token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'delivery_token');
    notifyListeners();
  }
}
