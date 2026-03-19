class Address {
  final String id;
  final String label;
  final String street;
  final String? district;
  final String city;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.street,
    this.district,
    required this.city,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Adresse',
      street: json['street'] as String? ?? '',
      district: json['district'] as String?,
      city: json['city'] as String? ?? 'Nouakchott',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'street': street,
    'district': district,
    'city': city,
    'isDefault': isDefault,
  };
}
