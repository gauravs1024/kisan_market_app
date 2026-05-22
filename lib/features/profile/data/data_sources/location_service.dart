import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/country_model.dart';
import '../models/state_model.dart';

class LocationService {
  final ApiClient apiClient;

  LocationService(this.apiClient);

  Future<List<CountryModel>> getCountries() async {
    try {
      AppLogger.d('LocationService: Fetching countries list');
      final response = await apiClient.get('api/public/countries');
      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        final list = responseData['data'] as List?;
        if (list != null) {
          return list.map((json) => CountryModel.fromJson(json)).toList();
        }
      }
      throw Exception(responseData['message']?.toString() ?? 'Failed to load countries');
    } catch (e) {
      AppLogger.e('LocationService: Failed to fetch countries: $e');
      rethrow;
    }
  }

  Future<List<StateModel>> getStates(int countryId) async {
    try {
      AppLogger.d('LocationService: Fetching states list for country ID: $countryId');
      final response = await apiClient.get('api/public/states/$countryId');
      final responseData = response.data;
      if (responseData is Map && responseData['status'] == true) {
        final list = responseData['data'] as List?;
        if (list != null) {
          return list.map((json) => StateModel.fromJson(json)).toList();
        }
      }
      throw Exception(responseData['message']?.toString() ?? 'Failed to load states');
    } catch (e) {
      AppLogger.e('LocationService: Failed to fetch states for country $countryId: $e');
      rethrow;
    }
  }
}
