import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<UserProfileEntity, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      fullName: params.fullName,
      email: params.email,
      address: params.address,
      city: params.city,
      state: params.state,
      pincode: params.pincode,
      imagePath: params.imagePath,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String fullName;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? imagePath;

  const UpdateProfileParams({
    required this.fullName,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.imagePath,
  });

  @override
  List<Object?> get props => [fullName, email, address, city, state, pincode, imagePath];
}
