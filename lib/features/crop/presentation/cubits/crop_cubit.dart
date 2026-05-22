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
      (crops) => emit(CropLoaded(crops)),
    );
  }
}
