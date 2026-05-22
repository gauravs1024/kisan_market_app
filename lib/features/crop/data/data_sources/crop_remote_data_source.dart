import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/crop_category_model.dart';
import '../models/crop_model.dart';

abstract class CropRemoteDataSource {
  Future<List<CropModel>> getCrops();
  Future<List<CropModel>> searchCrops(String keyword);
  Future<List<CropCategoryModel>> getCropCategories();
  Future<CropModel> getCropById(int id);
}

class CropRemoteDataSourceImpl implements CropRemoteDataSource {
  final ApiClient apiClient;

  CropRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CropModel>> getCrops() async {
    try {
      final response = await apiClient.get(ApiEndpoints.crops);
      final responseData = response.data;
      
      if (responseData is Map && responseData['status'] == true) {
        final dataMap = responseData['data'];
        if (dataMap is Map && dataMap['content'] is List) {
          final list = dataMap['content'] as List;
          return list.map((e) => CropModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      throw ServerException(message: 'Invalid response format from crops API');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crops: ${e.toString()}');
    }
  }

  @override
  Future<List<CropModel>> searchCrops(String keyword) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.searchCrops,
        queryParameters: {'keyword': keyword},
      );
      final responseData = response.data;
      
      if (responseData is Map && responseData['status'] == true) {
        final data = responseData['data'];
        if (data is List) {
          return data.map((e) => CropModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map && data['content'] is List) {
          final list = data['content'] as List;
          return list.map((e) => CropModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      throw ServerException(message: 'Invalid response format from search crops API');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to search crops: ${e.toString()}');
    }
  }

  @override
  Future<List<CropCategoryModel>> getCropCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.cropsCategory);
      final responseData = response.data;
      
      if (responseData is Map && responseData['status'] == true) {
        final dataList = responseData['data'];
        if (dataList is List) {
          return dataList.map((e) => CropCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      throw ServerException(message: 'Invalid response format from crops category API');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crop categories: ${e.toString()}');
    }
  }

  @override
  Future<CropModel> getCropById(int id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.cropDetail(id));
      final responseData = response.data;
      
      if (responseData is Map && responseData['status'] == true) {
        final dataMap = responseData['data'];
        if (dataMap is Map) {
          return CropModel.fromJson(dataMap as Map<String, dynamic>);
        }
      }
      throw ServerException(message: 'Invalid response format from crop detail API');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crop details: ${e.toString()}');
    }
  }
}
