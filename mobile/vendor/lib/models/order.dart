class OrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] ?? '',
        quantity: json['quantity'] ?? 1,
        price: (json['price'] ?? 0).toDouble(),
        productName: json['product']?['name'] ?? 'Produit',
      );
}

class VendorOrder {
  final String id;
  final String status;
  final String createdAt;
  final String customerName;
  final double total;
  final List<OrderItem> items;
  final String? customerPhone;
  final String? notes;

  const VendorOrder({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.total,
    required this.items,
    this.customerPhone,
    this.notes,
  });

  factory VendorOrder.fromJson(Map<String, dynamic> json) => VendorOrder(
        id: json['id'] ?? '',
        status: json['status'] ?? 'PENDING',
        createdAt: json['createdAt'] ?? '',
        customerName: json['customer']?['name'] ?? 'Client',
        customerPhone: json['customer']?['phone'],
        total: (json['total'] ?? 0).toDouble(),
        items: (json['items'] as List? ?? [])
            .map((i) => OrderItem.fromJson(i))
            .toList(),
        notes: json['notes'],
      );
}
