import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile();
  Future<Either<Failure, UserProfileEntity>> updateProfile({
    required String fullName,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? imagePath,
  });
}
