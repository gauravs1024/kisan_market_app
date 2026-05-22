import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_crops_usecase.dart';
import 'crop_search_state.dart';

class CropSearchCubit extends Cubit<CropSearchState> {
  final SearchCropsUseCase searchCropsUseCase;

  CropSearchCubit({required this.searchCropsUseCase}) : super(CropSearchInitial());

  Future<void> searchCrops(String keyword) async {
    if (keyword.trim().isEmpty) {
      emit(CropSearchInitial());
      return;
    }
    
    emit(CropSearchLoading());
    final result = await searchCropsUseCase(keyword.trim());
    result.fold(
      (failure) => emit(CropSearchError(failure.message)),
      (crops) => emit(CropSearchLoaded(crops)),
    );
  }

  void clearSearch() {
    emit(CropSearchInitial());
  }
}
