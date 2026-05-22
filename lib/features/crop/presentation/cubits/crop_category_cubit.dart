import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_crop_categories_usecase.dart';
import 'crop_category_state.dart';

class CropCategoryCubit extends Cubit<CropCategoryState> {
  final GetCropCategoriesUseCase getCropCategoriesUseCase;

  CropCategoryCubit({required this.getCropCategoriesUseCase}) : super(CropCategoryInitial());

  Future<void> fetchCropCategories() async {
    emit(CropCategoryLoading());
    final result = await getCropCategoriesUseCase(const NoParams());
    result.fold(
      (failure) => emit(CropCategoryError(failure.message)),
      (categories) => emit(CropCategoryLoaded(categories)),
    );
  }
}
