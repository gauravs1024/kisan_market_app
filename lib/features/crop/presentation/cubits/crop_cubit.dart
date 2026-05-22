import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_crops_usecase.dart';
import 'crop_state.dart';

class CropCubit extends Cubit<CropState> {
  final GetCropsUseCase getCropsUseCase;

  CropCubit({required this.getCropsUseCase}) : super(CropInitial());

  Future<void> fetchCrops() async {
    emit(CropLoading());
    final result = await getCropsUseCase(const NoParams());
    result.fold(
      (failure) => emit(CropError(failure.message)),
      (crops) => emit(CropLoaded(
        allCrops: crops,
        displayCrops: crops,
      )),
    );
  }

  void filterCrops({String? category, String? query}) {
    if (state is CropLoaded) {
      final currentState = state as CropLoaded;
      
      final newCategory = category ?? currentState.selectedCategory;
      final newQuery = query ?? currentState.searchQuery;

      final filteredCrops = currentState.allCrops.where((crop) {
        // Category filter
        final matchesCategory = newCategory == 'All' ||
            crop.categoryName.toLowerCase() == newCategory.toLowerCase();

        // Search text filter
        final searchLower = newQuery.toLowerCase();
        final matchesSearch = crop.name.toLowerCase().contains(searchLower) ||
            crop.localName.toLowerCase().contains(searchLower) ||
            crop.categoryName.toLowerCase().contains(searchLower);

        return matchesCategory && matchesSearch;
      }).toList();

      emit(currentState.copyWith(
        displayCrops: filteredCrops,
        selectedCategory: newCategory,
        searchQuery: newQuery,
      ));
    }
  }
}
