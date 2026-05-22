import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? category});
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product);
}
