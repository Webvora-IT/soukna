class Store {
  final String id;
  final String name;
  final String type;
  final String status;
  final String city;
  final String? nameAr;
  final String? description;
  final String? phone;
  final String? address;
  final String? district;
  final String? logo;
  final String? coverImage;
  final String? openTime;
  final String? closeTime;
  final double deliveryFee;
  final double minOrder;
  final double rating;
  final int reviewCount;
  final bool isOpen;

  const Store({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.city,
    this.nameAr,
    this.description,
    this.phone,
    this.address,
    this.district,
    this.logo,
    this.coverImage,
    this.openTime,
    this.closeTime,
    this.deliveryFee = 0,
    this.minOrder = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.isOpen = true,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        status: json['status'] ?? 'PENDING',
        city: json['city'] ?? 'Nouakchott',
        nameAr: json['nameAr'],
        description: json['description'],
        phone: json['phone'],
        address: json['address'],
        district: json['district'],
        logo: json['logo'],
        coverImage: json['coverImage'],
        openTime: json['openTime'],
        closeTime: json['closeTime'],
        deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
        minOrder: (json['minOrder'] ?? 0).toDouble(),
        rating: (json['rating'] ?? 0).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        isOpen: json['isOpen'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'status': status,
        'city': city,
        'nameAr': nameAr,
        'description': description,
        'phone': phone,
        'address': address,
        'district': district,
        'logo': logo,
        'coverImage': coverImage,
        'openTime': openTime,
        'closeTime': closeTime,
        'deliveryFee': deliveryFee,
        'minOrder': minOrder,
        'rating': rating,
        'reviewCount': reviewCount,
        'isOpen': isOpen,
      };

  Store copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? phone,
    String? address,
    String? district,
    String? city,
    String? logo,
    String? coverImage,
    String? openTime,
    String? closeTime,
    double? deliveryFee,
    double? minOrder,
    bool? isOpen,
  }) =>
      Store(
        id: id,
        name: name ?? this.name,
        type: type,
        status: status,
        city: city ?? this.city,
        nameAr: nameAr ?? this.nameAr,
        description: description ?? this.description,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        district: district ?? this.district,
        logo: logo ?? this.logo,
        coverImage: coverImage ?? this.coverImage,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        minOrder: minOrder ?? this.minOrder,
        rating: rating,
        reviewCount: reviewCount,
        isOpen: isOpen ?? this.isOpen,
      );
}
