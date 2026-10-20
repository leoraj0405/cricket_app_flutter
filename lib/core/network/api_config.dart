/// Central place for backend URLs, shared headers and timeouts.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://cricket-app-api.onrender.com';

  /// The API is hosted on Render, which can take a while to wake up from a
  /// cold start, so the timeout is deliberately generous.
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'x-client-type': 'mobile',
  };
}

/// All endpoint paths, relative to [ApiConfig.baseUrl].
class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/api/auth/login';
}
