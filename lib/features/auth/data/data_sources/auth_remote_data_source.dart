import 'package:kisan_market_app/core/network/api_endpoints.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String?> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp(String phoneNumber, String code);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<String?> sendOtp(String phoneNumber) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.sendOtp,
        data: {
          'phone': phoneNumber,
          'roleId': 2,
        },
      );
      
      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        final dataMap = responseData['data'];
        if (dataMap is Map && dataMap['OTP'] != null) {
          return dataMap['OTP'].toString();
        }
        return ''; // Success, but OTP not returned in body (sent via real SMS)
      }
      throw ServerException(
        message: responseData['message']?.toString() ?? 'Failed to send OTP',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to send OTP. Please check the number.',
      );
    }
  }

  @override
  Future<UserModel> verifyOtp(String phoneNumber, String code) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phoneNumber,
          'otp': code,
          'code': code, // Sending both key variations to ensure compatibility
        },
      );

      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        final dataMap = responseData['data'];
        if (dataMap is Map<String, dynamic>) {
          return UserModel.fromJson(dataMap);
        }
        // Fallback profile if data block is not nested
        return UserModel(
          id: responseData['id']?.toString() ?? 'live_user_id',
          phoneNumber: phoneNumber,
          name: responseData['name']?.toString() ?? 'Kisan User',
          token: responseData['token']?.toString() ?? 'live_token',
        );
      }
      throw ServerException(
        message: responseData['message']?.toString() ?? 'OTP Verification failed',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await apiClient.post(ApiEndpoints.logout);
      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        return;
      }
      throw ServerException(
        message: responseData['message']?.toString() ?? 'Logout failed',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Logout failed: ${e.toString()}');
    }
  }
}
