import '../core/network/api_config.dart';
import '../core/network/api_service.dart';
import '../core/storage/session_storage.dart';
import '../models/auth_session.dart';

class AuthService {
  AuthService({ApiService? api, SessionStorage? storage})
    : _api = api ?? ApiService(),
      _storage = storage ?? SessionStorage() {
    _api.tokenProvider = () async => _session?.accessToken;
  }

  final ApiService _api;
  final SessionStorage _storage;

  AuthSession? _session;
  AuthSession? get session => _session;
  bool get isLoggedIn => _session != null;

  /// Signs in and persists the session. Throws [ApiException] on failure.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post<AuthSession>(
      ApiEndpoints.login,
      authenticated: false,
      body: {'email': email, 'password': password},
      parser: (result) =>
          AuthSession.fromLoginJson(result as Map<String, dynamic>),
    );

    _session = response.result;
    await _storage.save(_session!);
    return _session!;
  }

  /// Creates an account. Returns the server message. Throws [ApiException].
  Future<String> register({
    required String userName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _postMessage(ApiEndpoints.register, {
      'userName': userName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  /// Emails a one-time code for resetting the password.
  Future<String> forgotPassword({required String email}) {
    return _postMessage(ApiEndpoints.forgotPassword, {'email': email});
  }

  /// Checks the emailed code before asking for a new password.
  Future<String> verifyOtp({required String email, required String otp}) {
    return _postMessage(ApiEndpoints.verifyOtp, {'email': email, 'otp': otp});
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _postMessage(ApiEndpoints.resetPassword, {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  /// For endpoints whose `result` the app doesn't use.
  Future<String> _postMessage(String path, Map<String, dynamic> body) async {
    final response = await _api.post<Object?>(
      path,
      authenticated: false,
      body: body,
      parser: (result) => result,
    );
    return response.message;
  }

  /// Loads a saved session on app start.
  Future<AuthSession?> restoreSession() async {
    _session = await _storage.read();
    return _session;
  }

  Future<void> logout() async {
    _session = null;
    await _storage.clear();
  }
}
