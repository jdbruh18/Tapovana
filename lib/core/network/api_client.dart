import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../errors/api_error.dart';

class ApiClient {
  ApiClient({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 8);

  final http.Client _client;
  final Duration _timeout;

  Future<List<dynamic>> getJsonList(String path) async {
    final decoded = await _getJson(path);
    if (decoded is! List<dynamic>) {
      throw ApiException('Unexpected response format', code: 'invalid_response');
    }
    return decoded;
  }

  Future<dynamic> _getJson(String path) async {
    final uri = _buildUri(path);
    http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Request timed out', code: 'timeout');
    } on http.ClientException {
      throw ApiException('Unable to reach server', code: 'network_error');
    }

    final bodyText = response.body;
    dynamic decoded;
    if (bodyText.isNotEmpty) {
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        throw ApiException('Invalid JSON response', statusCode: response.statusCode, code: 'invalid_json');
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw _mapHttpError(response.statusCode, decoded);
  }

  Uri _buildUri(String path) {
    final base = Uri.parse(ApiConfig.baseUrl);
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(normalizedPath);
  }

  ApiException _mapHttpError(int statusCode, dynamic body) {
    final messageFromBody = body is Map<String, dynamic>
        ? (body['message'] as String? ?? body['error'] as String?)
        : null;

    switch (statusCode) {
      case 400:
        return ApiException(messageFromBody ?? 'Invalid request', statusCode: statusCode, code: 'bad_request');
      case 401:
      case 403:
        return ApiException(messageFromBody ?? 'Access denied', statusCode: statusCode, code: 'forbidden');
      case 404:
        return ApiException(messageFromBody ?? 'Resource not found', statusCode: statusCode, code: 'not_found');
      case 408:
        return ApiException(messageFromBody ?? 'Request timed out', statusCode: statusCode, code: 'timeout');
      case 500:
      default:
        return ApiException(messageFromBody ?? 'Server error', statusCode: statusCode, code: 'server_error');
    }
  }
}
