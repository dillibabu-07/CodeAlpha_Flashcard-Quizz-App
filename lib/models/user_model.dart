// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'Admin' or 'Student'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
    );
  }

  bool get isAdmin => role == 'Admin';
  bool get isStudent => role == 'Student';
}
