class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code = 'api_error'});

  final String message;
  final int? statusCode;
  final String code;

  @override
  String toString() => 'ApiException(code: $code, statusCode: $statusCode, message: $message)';
}
