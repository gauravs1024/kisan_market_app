import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phoneNumber;
  final String name;
  final String token;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.token,
  });

  @override
  List<Object?> get props => [id, phoneNumber, name, token];
}
