import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final String selectedCategory;

  const ProductLoaded({
    required this.products,
    this.selectedCategory = 'All',
  });

  @override
  List<Object?> get props => [products, selectedCategory];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductAdding extends ProductState {}

class ProductAdded extends ProductState {
  final ProductEntity newProduct;

  const ProductAdded(this.newProduct);

  @override
  List<Object?> get props => [newProduct];
}
