import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/cache/shared_pref_manager.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPrefManager sharedPrefManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPrefManager,
  });

  @override
  Future<Either<Failure, String?>> sendOtp(String phoneNumber, {int? roleId}) async {
    try {
      AppLogger.d('Repository.sendOtp: Sending OTP request to remote for $phoneNumber');
      final otp = await remoteDataSource.sendOtp(phoneNumber, roleId: roleId);
      AppLogger.d('Repository.sendOtp: OTP request succeeded');
      return Right(otp);
    } on ServerException catch (e) {
      AppLogger.e('Repository.sendOtp: ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Repository.sendOtp: NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.e('Repository.sendOtp: Unexpected Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String phoneNumber, String code) async {
    try {
      AppLogger.d('Repository.verifyOtp: Verifying OTP $code for phone $phoneNumber');
      final userModel = await remoteDataSource.verifyOtp(phoneNumber, code);
      
      AppLogger.d('Repository.verifyOtp: Saving user session to local storage: User ID: ${userModel.id}');
      // Save data locally for persistent session storage
      await sharedPrefManager.saveUserData(
        token: userModel.token,
        userId: userModel.id,
        phone: userModel.phoneNumber,
        name: userModel.name,
      );

      AppLogger.i('Repository.verifyOtp: OTP verification and session caching succeeded');
      return Right(userModel);
    } on ServerException catch (e) {
      AppLogger.e('Repository.verifyOtp: ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Repository.verifyOtp: NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.e('Repository.verifyOtp: Unexpected Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      AppLogger.d('Repository.logout: Initiating logout');
      try {
        await remoteDataSource.logout();
        AppLogger.d('Repository.logout: Remote logout endpoint request succeeded');
      } catch (e) {
        AppLogger.w('Repository.logout: Remote logout endpoint request failed: $e. Proceeding to clear local storage anyway.');
      }
      await sharedPrefManager.clearAll();
      AppLogger.i('Repository.logout: Local storage cleared successfully');
      return const Right(null);
    } catch (e) {
      AppLogger.e('Repository.logout: Caught exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      AppLogger.d('Repository.getCachedUser: Loading session cache');
      final token = sharedPrefManager.getAuthToken();
      if (token != null && token.isNotEmpty) {
        final userId = sharedPrefManager.getString(SharedPrefKeys.userId) ?? '';
        final phone = sharedPrefManager.getString(SharedPrefKeys.userPhone) ?? '';
        final name = sharedPrefManager.getString(SharedPrefKeys.userName) ?? '';
        
        AppLogger.i('Repository.getCachedUser: Session found for User ID: $userId');
        return Right(UserModel(
          id: userId,
          phoneNumber: phone,
          name: name,
          token: token,
        ));
      }
      AppLogger.d('Repository.getCachedUser: No active cached session found');
      return const Right(null);
    } catch (e) {
      AppLogger.e('Repository.getCachedUser: Failed to load cached user details: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
