class Product {
  final String id;
  final String storeId;
  final String? categoryId;
  final String name;
  final String? nameAr;
  final String? description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String status;
  final int? stock;
  final String? unit;

  Product({
    required this.id,
    required this.storeId,
    this.categoryId,
    required this.name,
    this.nameAr,
    this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.status,
    this.stock,
    this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      storeId: json['storeId'],
      categoryId: json['categoryId'],
      name: json['name'],
      nameAr: json['nameAr'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'AVAILABLE',
      stock: json['stock'],
      unit: json['unit'],
    );
  }
}
