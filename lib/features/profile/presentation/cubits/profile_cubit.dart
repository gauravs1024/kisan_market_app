import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial());

  Future<void> fetchProfile() async {
    AppLogger.d('ProfileCubit: fetchProfile requested');
    emit(ProfileLoading());
    final result = await getProfileUseCase(const NoParams());
    result.fold(
      (failure) {
        AppLogger.e('ProfileCubit: fetchProfile failed: ${failure.message}');
        emit(ProfileError(message: failure.message));
      },
      (profile) {
        AppLogger.i('ProfileCubit: fetchProfile succeeded for User ID: ${profile.id}');
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? imagePath,
  }) async {
    AppLogger.i('ProfileCubit: updateProfile requested for $fullName');
    emit(ProfileUpdating());
    final result = await updateProfileUseCase(UpdateProfileParams(
      fullName: fullName,
      email: email,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      imagePath: imagePath,
    ));
    result.fold(
      (failure) {
        AppLogger.e('ProfileCubit: updateProfile failed: ${failure.message}');
        emit(ProfileError(message: failure.message));
      },
      (updatedProfile) {
        AppLogger.i('ProfileCubit: updateProfile succeeded');
        emit(ProfileUpdated(profile: updatedProfile));
        emit(ProfileLoaded(profile: updatedProfile));
      },
    );
  }
}
