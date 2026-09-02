import 'package:dio/dio.dart';

/// Typed network exception wrapper
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Check your backend server and network.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final responseData = error.response?.data;
        String msg = 'Received HTTP error $status';

        if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
          final errObj = responseData['error'];
          if (errObj is Map && errObj.containsKey('message')) {
            msg = errObj['message'].toString();
          }
        }
        return NetworkException(message: msg, statusCode: status);
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Cannot connect to backend server. Make sure server is running on http://localhost:5000.',
          statusCode: 503,
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');
      default:
        return NetworkException(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  @override
  String toString() => 'NetworkException($statusCode): $message';
}
