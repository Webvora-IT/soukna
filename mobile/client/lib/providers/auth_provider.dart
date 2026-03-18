import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _loading = true;

  User? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        _token = token;
        final res = await ApiService.getMe();
        _user = User.fromJson(res['data']);
      }
    } catch (e) {
      await ApiService.clearToken();
      _token = null;
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiService.login(email, password);
      if (res['success'] == true) {
        _token = res['data']['token'];
        _user = User.fromJson(res['data']['user']);
        await ApiService.saveToken(_token!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final res = await ApiService.register(data);
      if (res['success'] == true) {
        _token = res['data']['token'];
        _user = User.fromJson(res['data']['user']);
        await ApiService.saveToken(_token!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setUser(Map<String, dynamic> userData, String token) async {
    _token = token;
    _user = User.fromJson(userData);
    await ApiService.saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      final res = await ApiService.getMe();
      _user = User.fromJson(res['data']);
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }
}
