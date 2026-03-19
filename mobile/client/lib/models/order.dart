class OrderItem {
  final String id;
  final String productId;
  final String? productName;
  final int quantity;
  final double price;
  final String? notes;

  OrderItem({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.price,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['product']?['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      notes: json['notes'],
    );
  }
}

class Order {
  final String id;
  final String customerId;
  final String storeId;
  final String? storeName;
  final String? storeNameAr;
  final String status;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? notes;
  final int? estimatedTime;
  final int? rating;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.storeName,
    this.storeNameAr,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.notes,
    this.estimatedTime,
    this.rating,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      storeId: json['storeId'],
      storeName: json['store']?['name'],
      storeNameAr: json['store']?['nameAr'],
      status: json['status'],
      items: (json['items'] as List<dynamic>?)
          ?.map((i) => OrderItem.fromJson(i))
          .toList() ?? [],
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'],
      estimatedTime: json['estimatedTime'],
      rating: json['rating'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'storeId': storeId,
    'store': {'name': storeName, 'nameAr': storeNameAr},
    'status': status,
    'items': items.map((i) => {
      'id': i.id,
      'productId': i.productId,
      'product': {'name': i.productName},
      'quantity': i.quantity,
      'price': i.price,
      'notes': i.notes,
    }).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'notes': notes,
    'estimatedTime': estimatedTime,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
  };
}
