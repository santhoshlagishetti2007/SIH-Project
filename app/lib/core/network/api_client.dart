import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'api_result.dart';
import 'network_exceptions.dart';

/// Riverpod provider for the ApiClient singleton
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Centralized Dio-based HTTP client for Sanchari API
class ApiClient {
  late final Dio _dio;

  ApiClient({String? customBaseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  /// Attach or update the Firebase Auth bearer token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove auth token on logout
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Generic GET request wrapper returning ApiResult
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final responseData = response.data;

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return ApiResult.success(decoder(responseData['data']));
      }

      return ApiResult.success(decoder(responseData));
    } on DioException catch (e) {
      final netErr = NetworkException.fromDioError(e);
      return ApiResult.failure(netErr.message, statusCode: netErr.statusCode, error: e);
    } catch (e) {
      return ApiResult.failure('Unexpected error: $e', error: e);
    }
  }

  /// Generic POST request wrapper returning ApiResult
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      final responseData = response.data;

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return ApiResult.success(decoder(responseData['data']));
      }

      return ApiResult.success(decoder(responseData));
    } on DioException catch (e) {
      final netErr = NetworkException.fromDioError(e);
      return ApiResult.failure(netErr.message, statusCode: netErr.statusCode, error: e);
    } catch (e) {
      return ApiResult.failure('Unexpected error: $e', error: e);
    }
  }

  /// Generic PUT request wrapper returning ApiResult
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      final responseData = response.data;

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return ApiResult.success(decoder(responseData['data']));
      }

      return ApiResult.success(decoder(responseData));
    } on DioException catch (e) {
      final netErr = NetworkException.fromDioError(e);
      return ApiResult.failure(netErr.message, statusCode: netErr.statusCode, error: e);
    } catch (e) {
      return ApiResult.failure('Unexpected error: $e', error: e);
    }
  }

  /// Generic DELETE request wrapper returning ApiResult
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      final responseData = response.data;

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return ApiResult.success(decoder(responseData['data']));
      }

      return ApiResult.success(decoder(responseData));
    } on DioException catch (e) {
      final netErr = NetworkException.fromDioError(e);
      return ApiResult.failure(netErr.message, statusCode: netErr.statusCode, error: e);
    } catch (e) {
      return ApiResult.failure('Unexpected error: $e', error: e);
    }
  }
}
