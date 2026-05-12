import 'dart:convert';
import 'dart:io';

class RequestValidationException implements Exception {
  RequestValidationException(this.code, this.message, {this.statusCode = HttpStatus.badRequest});

  final String code;
  final String message;
  final int statusCode;
}

class RequestValidator {
  static Future<Map<String, dynamic>> readJsonBody(HttpRequest request) async {
    final rawBody = await utf8.decoder.bind(request).join();
    if (rawBody.trim().isEmpty) {
      throw RequestValidationException('empty_body', 'Request body cannot be empty');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawBody);
    } catch (error) {
      stderr.writeln('Invalid JSON payload: $error');
      throw RequestValidationException('invalid_json', 'Request body must be valid JSON');
    }

    if (decoded is! Map<String, dynamic>) {
      throw RequestValidationException('invalid_payload', 'Request body must be a JSON object');
    }

    return decoded;
  }

  static void validatePropertyPayload(Map<String, dynamic> payload) {
    final requiredKeys = <String>['id', 'name', 'imageAsset', 'rating', 'distanceKm', 'verified', 'prices', 'nextStarts'];
    final missing = requiredKeys.where((key) => payload[key] == null).toList();
    if (missing.isNotEmpty) {
      throw RequestValidationException(
        'missing_fields',
        'Missing required property fields',
        statusCode: HttpStatus.unprocessableEntity,
      );
    }

    if (payload['prices'] is! Map) {
      throw RequestValidationException(
        'invalid_prices',
        'prices must be an object keyed by duration',
        statusCode: HttpStatus.unprocessableEntity,
      );
    }

    if (payload['nextStarts'] is! List) {
      throw RequestValidationException(
        'invalid_next_starts',
        'nextStarts must be a list of time strings',
        statusCode: HttpStatus.unprocessableEntity,
      );
    }

    if (payload['id'] is! String ||
        payload['name'] is! String ||
        payload['imageAsset'] is! String ||
        payload['rating'] is! num ||
        payload['distanceKm'] is! num ||
        payload['verified'] is! bool) {
      throw RequestValidationException(
        'invalid_field_types',
        'One or more property fields have an invalid type',
        statusCode: HttpStatus.unprocessableEntity,
      );
    }
  }

  static void validatePathAndPayloadId(String pathId, Map<String, dynamic> payload) {
    if (payload['id'] != pathId) {
      throw RequestValidationException(
        'id_mismatch',
        'Property id in path must match payload id',
        statusCode: HttpStatus.unprocessableEntity,
      );
    }
  }
}
