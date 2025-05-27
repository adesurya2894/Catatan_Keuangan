class UserModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String status;
  final String dateCreated;
  final String? avatar;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.status,
    required this.dateCreated,
    this.avatar,
  });

  // Convert JSON ke model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      status: json['status'],
      dateCreated: json['dateCreated'],
      avatar: json['avatar'],
    );
  }

  // Convert model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'status': status,
      'dateCreated': dateCreated,
      'avatar': avatar,
    };
  }

  // ✅ Tambahan fungsi copyWith
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? status,
    String? dateCreated,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      avatar: avatar ?? this.avatar,
    );
  }
}
