import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    required super.name,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : json;
    return UserModel(
      id: (userMap['id'] ?? userMap['userId'] ?? json['id'] ?? json['userId'] ?? '').toString(),
      phoneNumber: (userMap['phoneNumber'] ?? userMap['phone'] ?? json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      name: (userMap['fullName'] ?? userMap['name'] ?? userMap['username'] ?? json['name'] ?? 'User').toString(),
      token: (json['token'] ?? json['accessToken'] ?? json['auth_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'token': token,
    };
  }
}
