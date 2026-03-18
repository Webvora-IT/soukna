import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  VendorUser? _user;
  String? _token;
  bool _loading = false;

  VendorUser? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  bool get isAuthenticated => _token != null && _user != null;

  Future<void> init() async {
    _token = await _storage.read(key: 'vendor_token');
    final userStr = await _storage.read(key: 'vendor_user');
    if (userStr != null && _token != null) {
      try {
        _user = VendorUser.fromJson(jsonDecode(userStr));
      } catch (_) {
        _token = null;
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await ApiService.login(email, password);
      if (result['success'] == true) {
        final data = result['data'];
        final userRole = data['user']['role'];
        if (userRole != 'VENDOR') {
          _loading = false;
          notifyListeners();
          return 'Ce compte n\'est pas un compte vendeur.';
        }
        _token = data['token'];
        _user = VendorUser.fromJson(data['user']);
        await _storage.write(key: 'vendor_token', value: _token);
        await _storage.write(
            key: 'vendor_user', value: jsonEncode(data['user']));
        _loading = false;
        notifyListeners();
        return null;
      }
      _loading = false;
      notifyListeners();
      return result['message'] ?? 'Erreur de connexion';
    } catch (e) {
      _loading = false;
      notifyListeners();
      return 'Erreur réseau. Vérifiez votre connexion.';
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _token = null;
    _user = null;
    notifyListeners();
  }
}
