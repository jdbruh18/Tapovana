import 'dart:convert';
import 'dart:io';

class JsonResponse {
  static Future<void> send(
    HttpRequest request,
    Object payload, {
    int status = HttpStatus.ok,
  }) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
    request.response.write(jsonEncode(payload));
    await request.response.close();
  }

  static Future<void> ok(HttpRequest request, Object data, {int status = HttpStatus.ok}) {
    return send(request, data, status: status);
  }

  static Future<void> error(
    HttpRequest request, {
    required int status,
    required String code,
    required String message,
    Map<String, Object?>? details,
  }) {
    return send(
      request,
      {
        'error': {
          'code': code,
          'message': message,
          if (details != null) 'details': details,
        },
      },
      status: status,
    );
  }
}
