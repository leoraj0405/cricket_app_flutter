import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'api_response.dart';

/// Common HTTP client for the whole app.
///
/// Every call:
///  * prefixes [ApiConfig.baseUrl] and adds the default headers
///    (including `x-client-type: mobile`),
///  * attaches `Authorization: Bearer <token>` when [tokenProvider] has one,
///  * applies [ApiConfig.timeout],
///  * decodes the `{ statusCode, message, isArray, result }` envelope,
///  * converts every failure into an [ApiException].
class ApiService {
  ApiService({http.Client? client, this.tokenProvider})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns the current access token, or null when signed out.
  Future<String?> Function()? tokenProvider;

  Future<ApiResponse<T>> get<T>(
    String path, {
    required T Function(dynamic result) parser,
    Map<String, String>? query,
    bool authenticated = true,
  }) {
    return _send(
      'GET',
      path,
      parser: parser,
      query: query,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    required T Function(dynamic result) parser,
    Object? body,
    bool authenticated = true,
  }) {
    return _send(
      'POST',
      path,
      parser: parser,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    required T Function(dynamic result) parser,
    Object? body,
    bool authenticated = true,
  }) {
    return _send(
      'PUT',
      path,
      parser: parser,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    required T Function(dynamic result) parser,
    Object? body,
    bool authenticated = true,
  }) {
    return _send(
      'PATCH',
      path,
      parser: parser,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic result) parser,
    Object? body,
    bool authenticated = true,
  }) {
    return _send(
      'DELETE',
      path,
      parser: parser,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> _send<T>(
    String method,
    String path, {
    required T Function(dynamic result) parser,
    Map<String, String>? query,
    Object? body,
    required bool authenticated,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);

    final headers = Map<String, String>.of(ApiConfig.defaultHeaders);
    if (authenticated && tokenProvider != null) {
      final token = await tokenProvider!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      final streamed = await _client.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed)
          .timeout(ApiConfig.timeout);
    } on SocketException {
      throw const ApiException(
        type: ApiErrorType.noInternet,
        message: 'No internet connection. Check your network and try again.',
      );
    } on TimeoutException {
      throw const ApiException(
        type: ApiErrorType.timeout,
        message: 'The server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiErrorType.noInternet,
        message: 'Could not reach the server. Please try again.',
      );
    }

    final json = _decode(response.body);
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    if (!isSuccess) {
      throw ApiException.fromStatusCode(
        response.statusCode,
        _extractErrorMessage(json),
      );
    }

    if (json is! Map<String, dynamic>) {
      throw ApiException(
        type: ApiErrorType.invalidResponse,
        statusCode: response.statusCode,
        message: 'Unexpected response from the server.',
      );
    }

    try {
      return ApiResponse.fromJson(json, parser);
    } catch (_) {
      throw ApiException(
        type: ApiErrorType.invalidResponse,
        statusCode: response.statusCode,
        message: 'Unexpected response from the server.',
      );
    }
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  /// Pulls a human-readable message out of an error body. Handles both
  /// `"message": "..."` and validation-style `"message": ["...", "..."]`.
  String? _extractErrorMessage(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final message = json['message'] ?? json['error'];
    if (message is String) return message;
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join('\n');
    }
    return null;
  }

  void close() => _client.close();
}
