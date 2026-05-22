import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crop_entity.dart';
import '../repositories/crop_repository.dart';

class SearchCropsUseCase implements UseCase<List<CropEntity>, String> {
  final CropRepository repository;

  SearchCropsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CropEntity>>> call(String keyword) {
    return repository.searchCrops(keyword);
  }
}
