import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String?>> sendOtp(String phoneNumber, {int? roleId});
  Future<Either<Failure, UserEntity>> verifyOtp(String phoneNumber, String code);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCachedUser();
}
