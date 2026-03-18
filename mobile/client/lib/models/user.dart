class User {
  final String id;
  final String email;
  final String? phone;
  final String name;
  final String? avatar;
  final String role;
  final String language;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.name,
    this.avatar,
    required this.role,
    required this.language,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      name: json['name'],
      avatar: json['avatar'],
      role: json['role'] ?? 'CUSTOMER',
      language: json['language'] ?? 'fr',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'phone': phone,
    'name': name, 'avatar': avatar, 'role': role,
    'language': language, 'isActive': isActive,
  };
}
