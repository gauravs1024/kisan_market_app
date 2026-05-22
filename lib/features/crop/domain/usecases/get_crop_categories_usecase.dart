import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/crop_category_entity.dart';
import '../repositories/crop_repository.dart';

class GetCropCategoriesUseCase implements UseCase<List<CropCategoryEntity>, NoParams> {
  final CropRepository repository;

  GetCropCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CropCategoryEntity>>> call(NoParams params) {
    return repository.getCropCategories();
  }
}
