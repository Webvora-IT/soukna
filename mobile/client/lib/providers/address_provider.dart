import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressProvider extends ChangeNotifier {
  List<Address> _addresses = [];
  bool _loading = false;
  bool _loaded = false;

  List<Address> get addresses => List.unmodifiable(_addresses);
  bool get loading => _loading;
  bool get loaded => _loaded;

  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    _loading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/users/addresses');
      _addresses = (res['data'] as List? ?? [])
          .map((a) => Address.fromJson(a as Map<String, dynamic>))
          .toList();
      _loaded = true;
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> addAddress(Map<String, dynamic> data) async {
    final res = await ApiService.post('/users/addresses', data);
    final address = Address.fromJson(res['data'] as Map<String, dynamic>);
    if (address.isDefault) {
      _addresses = _addresses.map((a) => Address(
        id: a.id, label: a.label, street: a.street,
        district: a.district, city: a.city, isDefault: false,
      )).toList();
    }
    _addresses.add(address);
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    await ApiService.delete('/users/addresses/$id');
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> setDefault(String id) async {
    await ApiService.patch('/users/addresses/$id', {'isDefault': true});
    _addresses = _addresses.map((a) => Address(
      id: a.id, label: a.label, street: a.street,
      district: a.district, city: a.city, isDefault: a.id == id,
    )).toList();
    notifyListeners();
  }

  void clearOnLogout() {
    _addresses = [];
    _loaded = false;
    notifyListeners();
  }
}
