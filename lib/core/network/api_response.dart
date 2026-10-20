/// The envelope every endpoint returns:
/// `{ statusCode, message, isArray, result }`.
class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.message,
    required this.isArray,
    required this.result,
  });

  final int statusCode;
  final String message;
  final bool isArray;
  final T result;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic result) parseResult,
  ) {
    return ApiResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      isArray: json['isArray'] as bool? ?? false,
      result: parseResult(json['result']),
    );
  }
}
