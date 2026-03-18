class VendorUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;

  const VendorUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
  });

  factory VendorUser.fromJson(Map<String, dynamic> json) => VendorUser(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        avatar: json['avatar'],
        phone: json['phone'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar': avatar,
        'phone': phone,
      };
}
