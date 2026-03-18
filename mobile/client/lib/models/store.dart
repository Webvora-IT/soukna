class Store {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String type;
  final String status;
  final String? logo;
  final String? coverImage;
  final String? phone;
  final String? address;
  final String? district;
  final String city;
  final double? lat;
  final double? lng;
  final String? openTime;
  final String? closeTime;
  final bool isOpen;
  final double deliveryFee;
  final double minOrder;
  final double rating;
  final int reviewCount;

  Store({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    required this.type,
    required this.status,
    this.logo,
    this.coverImage,
    this.phone,
    this.address,
    this.district,
    required this.city,
    this.lat,
    this.lng,
    this.openTime,
    this.closeTime,
    required this.isOpen,
    required this.deliveryFee,
    required this.minOrder,
    required this.rating,
    required this.reviewCount,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      logo: json['logo'],
      coverImage: json['coverImage'],
      phone: json['phone'],
      address: json['address'],
      district: json['district'],
      city: json['city'] ?? 'Nouakchott',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      isOpen: json['isOpen'] ?? true,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
