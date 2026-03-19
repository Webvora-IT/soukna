import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum DeliveryTab { available, myDeliveries }

class DeliveryOrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _availableOrders = [];
  List<Map<String, dynamic>> _myDeliveries = [];
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> get availableOrders => List.unmodifiable(_availableOrders);
  List<Map<String, dynamic>> get myDeliveries => List.unmodifiable(_myDeliveries);
  bool get loading => _loading;
  String? get error => _error;

  int get activeCount => _myDeliveries.where((o) => o['status'] == 'DELIVERING').length;
  int get availableCount => _availableOrders.length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        DeliveryApiService.getAssignedOrders(),
        DeliveryApiService.getMyDeliveries(),
      ]);
      _availableOrders = List<Map<String, dynamic>>.from(
        (results[0]['data'] as List? ?? []).where((o) => o['status'] == 'READY'),
      );
      _myDeliveries = List<Map<String, dynamic>>.from(
        (results[1]['data'] as List? ?? []).where((o) =>
          (o['status'] == 'DELIVERING' || o['status'] == 'DELIVERED') &&
          o['deliveryPersonId'] != null,
        ),
      );
    } catch (e) {
      _error = 'Impossible de charger les commandes';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptDelivery(String orderId) async {
    try {
      await DeliveryApiService.updateOrderStatus(orderId, 'DELIVERING');
      // Move from available to myDeliveries
      final idx = _availableOrders.indexWhere((o) => o['id'] == orderId);
      if (idx != -1) {
        final order = Map<String, dynamic>.from(_availableOrders[idx]);
        order['status'] = 'DELIVERING';
        _availableOrders.removeAt(idx);
        _myDeliveries.insert(0, order);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markDelivered(String orderId) async {
    try {
      await DeliveryApiService.updateOrderStatus(orderId, 'DELIVERED');
      final idx = _myDeliveries.indexWhere((o) => o['id'] == orderId);
      if (idx != -1) {
        _myDeliveries[idx] = Map<String, dynamic>.from(_myDeliveries[idx])
          ..['status'] = 'DELIVERED';
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void clear() {
    _availableOrders = [];
    _myDeliveries = [];
    notifyListeners();
  }
}
