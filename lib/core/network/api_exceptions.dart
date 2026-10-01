/// Base class for all application/API exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Thrown when there is no internet connection or socket failure
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Unable to connect to the server. Please check your internet connection.',
  ]);
}

/// Thrown when request exceeds timeout threshold
class ApiTimeoutException extends AppException {
  const ApiTimeoutException([
    super.message = 'The connection timed out. Please try again later.',
  ]);
}

/// Thrown for 400 Bad Request
class BadRequestException extends AppException {
  const BadRequestException([
    super.message = 'Bad request sent to server.',
    super.statusCode = 400,
  ]);
}

/// Thrown for 404 Not Found
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Requested resource not found.',
    super.statusCode = 404,
  ]);
}

/// Thrown for 5xx Server Errors
class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error occurred. Please try again later.',
    super.statusCode = 500,
  ]);
}

/// Thrown when JSON parsing/serialization fails
class SerializationException extends AppException {
  const SerializationException([
    super.message = 'Failed to parse response data.',
  ]);
}

/// Generic unexpected exception
class UnexpectedApiException extends AppException {
  const UnexpectedApiException([
    super.message = 'An unexpected error occurred.',
    super.statusCode,
  ]);
}
