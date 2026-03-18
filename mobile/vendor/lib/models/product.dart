class Product {
  final String id;
  final String storeId;
  final String name;
  final String status;
  final String? nameAr;
  final String? nameEn;
  final String? description;
  final String? categoryId;
  final String? rejectionReason;
  final String? unit;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final int? stock;
  final String createdAt;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.status,
    required this.price,
    required this.images,
    required this.createdAt,
    this.nameAr,
    this.nameEn,
    this.description,
    this.categoryId,
    this.rejectionReason,
    this.unit,
    this.originalPrice,
    this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] ?? '',
        storeId: json['storeId'] ?? '',
        name: json['name'] ?? '',
        status: json['status'] ?? 'PENDING_REVIEW',
        price: (json['price'] ?? 0).toDouble(),
        images: List<String>.from(json['images'] ?? []),
        createdAt: json['createdAt'] ?? '',
        nameAr: json['nameAr'],
        nameEn: json['nameEn'],
        description: json['description'],
        categoryId: json['categoryId'],
        rejectionReason: json['rejectionReason'],
        unit: json['unit'],
        originalPrice: json['originalPrice']?.toDouble(),
        stock: json['stock'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'name': name,
        'status': status,
        'price': price,
        'images': images,
        'createdAt': createdAt,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'description': description,
        'categoryId': categoryId,
        'rejectionReason': rejectionReason,
        'unit': unit,
        'originalPrice': originalPrice,
        'stock': stock,
      };
}
