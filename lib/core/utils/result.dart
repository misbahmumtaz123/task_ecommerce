import '../network/api_exceptions.dart';

/// A generic class representing either a successful result or a failure
sealed class Result<T> {
  const Result();

  /// Creates a success result containing [data]
  factory Result.success(T data) = Success<T>;

  /// Creates a failure result containing an [exception]
  factory Result.failure(AppException exception) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final data) => data,
        Failure() => null,
      };

  AppException? get exceptionOrNull => switch (this) {
        Success() => null,
        Failure(exception: final exception) => exception,
      };

  /// Pattern matching helper
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(exception: final exception) => failure(exception),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}
