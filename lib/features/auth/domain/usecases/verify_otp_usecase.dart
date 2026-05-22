import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<UserEntity, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) {
    return repository.verifyOtp(params.phoneNumber, params.code);
  }
}

class VerifyOtpParams {
  final String phoneNumber;
  final String code;
  const VerifyOtpParams({required this.phoneNumber, required this.code});
}
