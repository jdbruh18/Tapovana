import 'dart:io';

import '../core/json_response.dart';
import '../core/request_validator.dart';
import '../handlers/property_handler.dart';
import '../handlers/proxy_handler.dart';
import '../integrations/integrations_config.dart';

class AppRouter {
  AppRouter({
    required PropertyHandler propertyHandler,
    required ProxyHandler proxyHandler,
    required IntegrationsConfig integrations,
  })  : _propertyHandler = propertyHandler,
        _proxyHandler = proxyHandler,
        _integrations = integrations;

  final PropertyHandler _propertyHandler;
  final ProxyHandler _proxyHandler;
  final IntegrationsConfig _integrations;

  Future<void> route(HttpRequest request) async {
    _setCorsHeaders(request);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    try {
      if (path == '/health' && request.method == 'GET') {
        await JsonResponse.ok(request, {
          'ok': true,
          'integrations': {
            'razorpayConfigured': _integrations.razorpay.isConfigured,
            'otpProvider': _integrations.otp.provider,
            'smsProvider': _integrations.notifications.smsProvider,
            'whatsappProvider': _integrations.notifications.whatsappProvider,
          },
        });
        return;
      }

      if (path == '/properties' && request.method == 'GET') {
        await _propertyHandler.list(request);
        return;
      }
      if (path == '/properties' && request.method == 'POST') {
        await _propertyHandler.create(request);
        return;
      }
      if (path.startsWith('/properties/') && request.method == 'PUT') {
        final id = _extractResourceId(path);
        if (id == null) {
          await JsonResponse.error(
            request,
            status: HttpStatus.badRequest,
            code: 'invalid_property_id',
            message: 'Property id is missing from request path',
          );
          return;
        }
        await _propertyHandler.update(request, id);
        return;
      }
      if (path.startsWith('/properties/') && request.method == 'DELETE') {
        final id = _extractResourceId(path);
        if (id == null) {
          await JsonResponse.error(
            request,
            status: HttpStatus.badRequest,
            code: 'invalid_property_id',
            message: 'Property id is missing from request path',
          );
          return;
        }
        await _propertyHandler.delete(request, id);
        return;
      }
      if (path == '/proxy' && request.method == 'GET') {
        await _proxyHandler.proxy(request);
        return;
      }

      await JsonResponse.error(
        request,
        status: HttpStatus.notFound,
        code: 'not_found',
        message: 'Route not found',
      );
    } on RequestValidationException catch (error) {
      await JsonResponse.error(
        request,
        status: error.statusCode,
        code: error.code,
        message: error.message,
      );
    } catch (error) {
      stderr.writeln('Unhandled route error on ${request.method} $path: $error');
      await JsonResponse.error(
        request,
        status: HttpStatus.internalServerError,
        code: 'internal_server_error',
        message: 'An unexpected server error occurred',
      );
    }
  }

  void _setCorsHeaders(HttpRequest request) {
    request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Content-Type');
  }

  String? _extractResourceId(String path) {
    final segments = Uri.parse(path).pathSegments;
    if (segments.length < 2) {
      return null;
    }
    final id = segments.last;
    return id.isEmpty ? null : id;
  }
}
