import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _currentOrder;
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  Map<String, dynamic>? get currentOrder => _currentOrder;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  int get activeOrderCount => _orders.where((o) {
    final s = o['status'] as String? ?? '';
    return ['PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'DELIVERING'].contains(s);
  }).length;

  List<Map<String, dynamic>> filtered(String? status) {
    if (status == null) return _orders;
    return _orders.where((o) => o['status'] == status).toList();
  }

  Future<void> loadOrders({bool force = false, String? status}) async {
    if (_loaded && !force && status == null) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final path = status != null ? '/orders?status=$status' : '/orders';
      final res = await ApiService.get(path);
      _orders = List<Map<String, dynamic>>.from(res['data'] as List? ?? []);
      _loaded = true;
    } catch (e) {
      _error = 'Impossible de charger les commandes';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrder(String id) async {
    try {
      final res = await ApiService.getOrder(id);
      _currentOrder = res['data'] as Map<String, dynamic>?;
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> data) async {
    try {
      final res = await ApiService.createOrder(data);
      if (res['success'] == true) {
        final order = res['data'] as Map<String, dynamic>;
        _orders.insert(0, order);
        notifyListeners();
        return order;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  void clear() {
    _orders = [];
    _currentOrder = null;
    _loaded = false;
    notifyListeners();
  }
}
