import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;

  ProductCubit({
    required this.getProductsUseCase,
    required this.addProductUseCase,
  }) : super(ProductInitial());

  Future<void> fetchProducts({String category = 'All'}) async {
    emit(ProductLoading());
    final result = await getProductsUseCase(GetProductsParams(
      category: category == 'All' ? null : category,
    ));

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products: products, selectedCategory: category)),
    );
  }

  Future<void> addProduct(ProductEntity product) async {
    // Save current state to restore if needed
    final currentState = state;
    List<ProductEntity> currentProducts = [];
    String currentCategory = 'All';

    if (currentState is ProductLoaded) {
      currentProducts = currentState.products;
      currentCategory = currentState.selectedCategory;
    }

    emit(ProductAdding());
    
    final result = await addProductUseCase(AddProductParams(product: product));

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (newProduct) {
        emit(ProductAdded(newProduct));
        // Reload products or append directly to list for a smoother UI experience
        final updatedProducts = List<ProductEntity>.from(currentProducts)..insert(0, newProduct);
        emit(ProductLoaded(products: updatedProducts, selectedCategory: currentCategory));
      },
    );
  }
}
