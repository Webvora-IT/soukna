import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? notes;

  CartItem({required this.product, this.quantity = 1, this.notes});

  double get total => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _storeId;
  String? _storeName;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get storeId => _storeId;
  String? get storeName => _storeName;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.total);
  bool get isEmpty => _items.isEmpty;

  void addItem(Product product, {String? storeNameParam}) {
    // If adding from different store, clear cart
    if (_storeId != null && _storeId != product.storeId) {
      _items.clear();
    }
    _storeId = product.storeId;
    if (storeNameParam != null) _storeName = storeNameParam;

    final existing = _items.where((i) => i.product.id == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    if (_items.isEmpty) {
      _storeId = null;
      _storeName = null;
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final item = _items.where((i) => i.product.id == productId).firstOrNull;
    if (item != null) {
      item.quantity = qty;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _storeId = null;
    _storeName = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _items.map((i) => {
      'productId': i.product.id,
      'quantity': i.quantity,
      if (i.notes != null) 'notes': i.notes,
    }).toList();
  }
}
