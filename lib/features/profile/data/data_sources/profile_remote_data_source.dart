import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    required String fullName,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? imagePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      AppLogger.d('ProfileRemoteDataSource: Fetching user profile');
      final response = await apiClient.get(ApiEndpoints.profile);
      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        final dataMap = responseData['data'];
        if (dataMap is Map<String, dynamic>) {
          return UserProfileModel.fromJson(dataMap);
        }
      }
      throw ServerException(
        message: responseData['message']?.toString() ?? 'Failed to fetch profile details',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      AppLogger.e('ProfileRemoteDataSource: Failed to fetch profile: $e');
      throw ServerException(message: 'Failed to retrieve profile: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String fullName,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? imagePath,
  }) async {
    try {
      AppLogger.d('ProfileRemoteDataSource: Updating user profile (Multipart form-data)');
      
      final Map<String, dynamic> fields = {
        'fullName': fullName,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      };

      if (imagePath != null && imagePath.isNotEmpty) {
        AppLogger.d('ProfileRemoteDataSource: Attaching profile image file: $imagePath');
        fields['profileImage'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(fields);

      final response = await apiClient.put(
        ApiEndpoints.profile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        final dataMap = responseData['data'];
        if (dataMap is Map<String, dynamic>) {
          return UserProfileModel.fromJson(dataMap);
        }
      }
      throw ServerException(
        message: responseData['message']?.toString() ?? 'Failed to update profile details',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      AppLogger.e('ProfileRemoteDataSource: Failed to update profile with PUT: $e');
      // If PUT fails, try POST as a fallback since some servers treat PUT as POST or vice-versa
      try {
        AppLogger.w('ProfileRemoteDataSource: PUT failed. Trying POST fallback for profile update...');
        final Map<String, dynamic> fields = {
          'fullName': fullName,
          'email': email,
          'address': address,
          'city': city,
          'state': state,
          'pincode': pincode,
        };

        if (imagePath != null && imagePath.isNotEmpty) {
          fields['profileImage'] = await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          );
        }

        final formData = FormData.fromMap(fields);

        final response = await apiClient.post(
          ApiEndpoints.profile,
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );
        final responseData = response.data;
        if (responseData is Map && responseData['status'] == true) {
          final dataMap = responseData['data'];
          if (dataMap is Map<String, dynamic>) {
            return UserProfileModel.fromJson(dataMap);
          }
        }
        throw ServerException(
          message: responseData['message']?.toString() ?? 'Failed to update profile details',
        );
      } catch (postError) {
        AppLogger.e('ProfileRemoteDataSource: POST fallback failed: $postError');
        throw ServerException(message: 'Failed to update profile: ${postError.toString()}');
      }
    }
  }
}
