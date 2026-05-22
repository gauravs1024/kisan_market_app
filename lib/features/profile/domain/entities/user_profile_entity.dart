import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final int id;
  final String? fullName;
  final String? email;
  final String phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String role;
  final String accountStatus;
  final String kycStatus;
  final bool isVerified;
  final String createdAt;

  const UserProfileEntity({
    required this.id,
    this.fullName,
    this.email,
    required this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    required this.role,
    required this.accountStatus,
    required this.kycStatus,
    required this.isVerified,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        address,
        city,
        state,
        pincode,
        role,
        accountStatus,
        kycStatus,
        isVerified,
        createdAt,
      ];
}
