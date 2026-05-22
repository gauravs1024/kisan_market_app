import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crop_entity.dart';
import '../repositories/crop_repository.dart';

class GetCropsUseCase implements UseCase<List<CropEntity>, NoParams> {
  final CropRepository repository;

  GetCropsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CropEntity>>> call(NoParams params) {
    return repository.getCrops();
  }
}
