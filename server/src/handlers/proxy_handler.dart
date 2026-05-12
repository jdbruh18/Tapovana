import 'dart:io';

import '../core/json_response.dart';
import '../services/proxy_service.dart';

class ProxyHandler {
  ProxyHandler({ProxyService? service}) : _service = service ?? ProxyService();

  final ProxyService _service;

  Future<void> proxy(HttpRequest request) async {
    final rawUrl = request.uri.queryParameters['url'];
    if (rawUrl == null || rawUrl.isEmpty) {
      await JsonResponse.error(
        request,
        status: HttpStatus.badRequest,
        code: 'missing_url',
        message: 'Query parameter "url" is required',
      );
      return;
    }

    final result = await _service.fetchImage(rawUrl);
    if (!result.isSuccess) {
      await JsonResponse.error(
        request,
        status: result.statusCode,
        code: result.errorCode ?? 'proxy_error',
        message: result.message ?? 'Proxy request failed',
      );
      return;
    }

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = result.contentType;
    request.response.headers.set('Cache-Control', 'public, max-age=3600');
    request.response.add(result.bytes!);
    await request.response.close();
  }
}
