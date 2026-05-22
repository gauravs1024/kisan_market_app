import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_crop_by_id_usecase.dart';
import 'crop_detail_state.dart';

class CropDetailCubit extends Cubit<CropDetailState> {
  final GetCropByIdUseCase getCropByIdUseCase;

  CropDetailCubit({required this.getCropByIdUseCase}) : super(CropDetailInitial());

  Future<void> fetchCropById(int id) async {
    emit(CropDetailLoading());
    final result = await getCropByIdUseCase(id);
    result.fold(
      (failure) => emit(CropDetailError(failure.message)),
      (crop) => emit(CropDetailLoaded(crop)),
    );
  }
}
