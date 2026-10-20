import 'user.dart';

/// The `result` object of a successful login.
class AuthSession {
  const AuthSession({
    required this.tokenType,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  final String tokenType;
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime? refreshTokenExpiresAt;
  final User user;

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiresAt);

  /// Builds a session from the login response. `expiresIn` is in seconds,
  /// so it is converted to an absolute time here.
  factory AuthSession.fromLoginJson(Map<String, dynamic> json) {
    final expiresIn = (json['expiresIn'] as num?)?.toInt() ?? 0;
    return AuthSession(
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.tryParse(
        json['refreshTokenExpiresAt']?.toString() ?? '',
      ),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Restores a session previously written with [toJson].
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      tokenType: json['tokenType'] as String,
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt']),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.tryParse(
        json['refreshTokenExpiresAt']?.toString() ?? '',
      ),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'tokenType': tokenType,
    'accessToken': accessToken,
    'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
    'refreshToken': refreshToken,
    'refreshTokenExpiresAt': refreshTokenExpiresAt?.toIso8601String(),
    'user': user.toJson(),
  };
}
