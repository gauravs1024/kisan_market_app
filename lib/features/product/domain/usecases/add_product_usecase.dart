import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class AddProductUseCase implements UseCase<ProductEntity, AddProductParams> {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(AddProductParams params) {
    return repository.addProduct(params.product);
  }
}

class AddProductParams {
  final ProductEntity product;
  const AddProductParams({required this.product});
}
