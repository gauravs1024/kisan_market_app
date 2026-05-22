import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_cached_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;

  AuthCubit({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.getCachedUserUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    AppLogger.d('checkAuthStatus: Checking cached user session');
    final result = await getCachedUserUseCase(const NoParams());
    result.fold(
      (failure) {
        AppLogger.w('checkAuthStatus: No user cached. Emitting UnauthenticatedState');
        emit(UnauthenticatedState());
      },
      (user) {
        if (user != null) {
          AppLogger.i('checkAuthStatus: Cached session found for User ID: ${user.id}. Emitting AuthenticatedState');
          emit(AuthenticatedState(user: user));
        } else {
          AppLogger.w('checkAuthStatus: User cached model was null. Emitting UnauthenticatedState');
          emit(UnauthenticatedState());
        }
      },
    );
  }

  Future<void> sendOtp(String phoneNumber) async {
    AppLogger.i('sendOtp: Requesting OTP for phone: $phoneNumber');
    emit(AuthLoading());
    final result = await sendOtpUseCase(SendOtpParams(phoneNumber: phoneNumber));
    result.fold(
      (failure) {
        AppLogger.e('sendOtp: Request failed: ${failure.message}');
        emit(AuthErrorState(message: failure.message));
      },
      (otpCode) {
        AppLogger.i('sendOtp: OTP sent successfully. Received Test OTP: $otpCode');
        emit(OtpSentState(phoneNumber: phoneNumber, otpCode: otpCode));
      },
    );
  }

  Future<void> verifyOtp(String phoneNumber, String code) async {
    AppLogger.i('verifyOtp: Verifying OTP for phone: $phoneNumber');
    emit(AuthLoading());
    final result = await verifyOtpUseCase(VerifyOtpParams(
      phoneNumber: phoneNumber,
      code: code,
    ));
    result.fold(
      (failure) {
        AppLogger.e('verifyOtp: Verification failed: ${failure.message}');
        emit(AuthErrorState(message: failure.message));
      },
      (user) {
        AppLogger.i('verifyOtp: Verification succeeded. User ID: ${user.id}. Emitting AuthenticatedState');
        emit(AuthenticatedState(user: user));
      },
    );
  }

  Future<void> logout() async {
    AppLogger.i('logout: Initiating logout flow');
    emit(AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) {
        AppLogger.e('logout: Logout failed: ${failure.message}');
        emit(AuthErrorState(message: failure.message));
      },
      (_) {
        AppLogger.i('logout: Logout succeeded. Emitting UnauthenticatedState');
        emit(UnauthenticatedState());
      },
    );
  }
  
  // Helper method to go back from OTP input screen to phone entry screen
  void cancelOtpCodeSent() {
    AppLogger.d('cancelOtpCodeSent: Canceling OTP code verification, returning to UnauthenticatedState');
    emit(UnauthenticatedState());
  }
}
