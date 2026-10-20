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
