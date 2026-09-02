/// Generic Result monad for clean error handling across layers
sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.failure(String message, {int? statusCode, dynamic error}) =
      Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode, dynamic error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else if (this is Failure<T>) {
      final f = this as Failure<T>;
      return failure(f.message, f.statusCode, f.error);
    }
    throw StateError('Unknown ApiResult subtype');
  }
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure(this.message, {this.statusCode, this.error});
}
