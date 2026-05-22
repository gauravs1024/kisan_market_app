import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase implements UseCase<String?, SendOtpParams> {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(SendOtpParams params) {
    return repository.sendOtp(params.phoneNumber);
  }
}

class SendOtpParams {
  final String phoneNumber;
  const SendOtpParams({required this.phoneNumber});
}
