import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    super.fullName,
    super.email,
    required super.phone,
    super.address,
    super.city,
    super.state,
    super.pincode,
    required super.role,
    required super.accountStatus,
    required super.kycStatus,
    required super.isVerified,
    required super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      role: json['role'] as String? ?? 'ROLE_BUYER',
      accountStatus: json['accountStatus'] as String? ?? 'ACTIVE',
      kycStatus: json['kycStatus'] as String? ?? 'NOT_SUBMITTED',
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'role': role,
      'accountStatus': accountStatus,
      'kycStatus': kycStatus,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }
}
