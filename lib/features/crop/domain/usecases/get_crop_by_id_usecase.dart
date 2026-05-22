import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crop_entity.dart';
import '../repositories/crop_repository.dart';

class GetCropByIdUseCase implements UseCase<CropEntity, int> {
  final CropRepository repository;

  GetCropByIdUseCase(this.repository);

  @override
  Future<Either<Failure, CropEntity>> call(int params) {
    return repository.getCropById(params);
  }
}
