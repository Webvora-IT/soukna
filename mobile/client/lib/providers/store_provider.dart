import 'package:flutter/material.dart';
import '../models/store.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class StoreProvider extends ChangeNotifier {
  List<Store> _stores = [];
  List<Category> _categories = [];
  String? _selectedType;
  String _search = '';
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Store> get stores => _stores;
  List<Category> get categories => _categories;
  String? get selectedType => _selectedType;
  String get search => _search;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  List<Store> get filteredStores {
    return _stores.where((s) =>
      (_search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase())) &&
      (_selectedType == null || s.type == _selectedType)
    ).toList();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> loadData({bool force = false}) async {
    if (_loaded && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.getStores(),
        ApiService.getCategories(),
      ]);
      _stores = (results[0]['data'] as List).map((s) => Store.fromJson(s)).toList();
      _categories = (results[1]['data'] as List).map((c) => Category.fromJson(c)).toList();
      _loaded = true;
    } catch (e) {
      _error = 'Impossible de charger les boutiques';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadData(force: true);

  void resetFilters() {
    _search = '';
    _selectedType = null;
    notifyListeners();
  }

  void clear() {
    _stores = [];
    _categories = [];
    _search = '';
    _selectedType = null;
    _loaded = false;
    notifyListeners();
  }
}
