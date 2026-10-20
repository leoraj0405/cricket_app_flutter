enum ApiErrorType {
  noInternet,
  timeout,
  unauthorized,
  badRequest,
  notFound,
  server,
  invalidResponse,
  unknown,
}

/// The single error type thrown by [ApiService]. The UI only needs to show
/// [message]; [type] and [statusCode] are there for branching logic.
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  factory ApiException.fromStatusCode(int statusCode, String? serverMessage) {
    final hasMessage = serverMessage != null && serverMessage.trim().isNotEmpty;

    final ApiErrorType type;
    final String fallback;
    if (statusCode == 401 || statusCode == 403) {
      type = ApiErrorType.unauthorized;
      fallback = 'Invalid email or password.';
    } else if (statusCode == 404) {
      type = ApiErrorType.notFound;
      fallback = 'The requested resource was not found.';
    } else if (statusCode >= 400 && statusCode < 500) {
      type = ApiErrorType.badRequest;
      fallback = 'Please check the details you entered.';
    } else if (statusCode >= 500) {
      type = ApiErrorType.server;
      fallback = 'Server error. Please try again in a moment.';
    } else {
      type = ApiErrorType.unknown;
      fallback = 'Something went wrong. Please try again.';
    }

    return ApiException(
      type: type,
      statusCode: statusCode,
      message: hasMessage ? serverMessage.trim() : fallback,
    );
  }

  @override
  String toString() => 'ApiException($type, $statusCode): $message';
}
