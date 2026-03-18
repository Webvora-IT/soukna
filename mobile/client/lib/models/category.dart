class Category {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? icon;
  final String? image;
  final String? storeType;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.icon,
    this.image,
    this.storeType,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      icon: json['icon'],
      image: json['image'],
      storeType: json['storeType'],
      isActive: json['isActive'] ?? true,
    );
  }
}
