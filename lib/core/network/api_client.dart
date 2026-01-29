import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;
  
  ApiClient(this._dio, this._secureStorage) {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: AppConfig.connectTimeout);
    _dio.options.receiveTimeout = const Duration(milliseconds: AppConfig.receiveTimeout);
    
    // Request interceptor - Add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 - Refresh token
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await _secureStorage.getRefreshToken();
            if (refreshToken != null) {
              // Attempt token refresh
              final response = await _dio.post('/auth/refresh-token', data: {
                'refreshToken': refreshToken,
              });
              
              final newAccessToken = response.data['data']['accessToken'];
              final newRefreshToken = response.data['data']['refreshToken'];
              
              await _secureStorage.saveAccessToken(newAccessToken);
              await _secureStorage.saveRefreshToken(newRefreshToken);
              
              // Retry original request
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              return handler.resolve(await _dio.fetch(opts));
            }
          } catch (e) {
            // Refresh failed - logout user
            await _secureStorage.deleteTokens();
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));
  }
  
  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout', 'TIMEOUT');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        if (data is Map<String, dynamic>) {
          return ApiException(
            data['message'] ?? 'Request failed',
            data['error'] ?? 'ERROR',
            statusCode: statusCode,
          );
        }
        return ApiException('Request failed', 'ERROR', statusCode: statusCode);
      
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', 'CANCELLED');
      
      default:
        return ApiException('Network error. Please check your connection.', 'NETWORK_ERROR');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;
  
  ApiException(this.message, this.errorCode, {this.statusCode});
  
  @override
  String toString() => message;
}

// Provider
final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});
