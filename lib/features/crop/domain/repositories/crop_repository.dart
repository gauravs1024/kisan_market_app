import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crop_category_entity.dart';
import '../entities/crop_entity.dart';

abstract class CropRepository {
  Future<Either<Failure, List<CropEntity>>> getCrops();
  Future<Either<Failure, List<CropEntity>>> searchCrops(String keyword);
  Future<Either<Failure, List<CropCategoryEntity>>> getCropCategories();
  Future<Either<Failure, CropEntity>> getCropById(int id);
}
