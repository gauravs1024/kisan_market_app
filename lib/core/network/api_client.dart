import 'package:dio/dio.dart';
import '../cache/shared_pref_manager.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';
import 'api_endpoints.dart';

class ApiClient {
  final Dio _dio;
  final SharedPrefManager _sharedPrefManager;

  ApiClient(this._dio, this._sharedPrefManager) {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl, 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Interceptor to automatically add the Bearer token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _sharedPrefManager.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      AppLogger.d('ApiClient.GET: $path | Params: $queryParameters');
      final response = await _dio.get(path, queryParameters: queryParameters);
      AppLogger.d('ApiClient.GET Succeeded: $path');
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      AppLogger.d('ApiClient.POST: $path | Data: $data');
      final response = await _dio.post(path, data: data, options: options);
      AppLogger.d('ApiClient.POST Succeeded: $path');
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    try {
      AppLogger.d('ApiClient.PUT: $path | Data: $data');
      final response = await _dio.put(path, data: data, options: options);
      AppLogger.d('ApiClient.PUT Succeeded: $path');
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    AppLogger.e('ApiClient.API ERROR on ${e.requestOptions.method} ${e.requestOptions.path} | Error: ${e.message}', e, e.stackTrace);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(message: 'Network timeout. Check your connection.');
    }
    
    if (e.response != null) {
      final data = e.response?.data;
      final message = (data is Map && data.containsKey('message')) 
          ? data['message'] 
          : 'Server returned error: ${e.response?.statusCode}';
      return ServerException(message: message);
    }

    return ServerException(message: 'Something went wrong: ${e.message}');
  }
}
