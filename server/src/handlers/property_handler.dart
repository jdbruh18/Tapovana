import 'dart:io';

import '../core/json_response.dart';
import '../core/request_validator.dart';
import '../data/property_repository.dart';
import '../services/property_service.dart';

class PropertyHandler {
  PropertyHandler(PropertyRepository repository) : _service = PropertyService(repository);

  final PropertyService _service;

  Future<void> list(HttpRequest request) async {
    final properties = await _service.listProperties();
    await JsonResponse.ok(request, properties);
  }

  Future<void> create(HttpRequest request) async {
    final payload = await RequestValidator.readJsonBody(request);
    await _service.createProperty(payload);
    await JsonResponse.ok(request, {'ok': true, 'message': 'Property added successfully'}, status: HttpStatus.created);
  }

  Future<void> update(HttpRequest request, String id) async {
    final payload = await RequestValidator.readJsonBody(request);
    final updated = await _service.updateProperty(id, payload);
    if (!updated) {
      await JsonResponse.error(
        request,
        status: HttpStatus.notFound,
        code: 'property_not_found',
        message: 'Property with id $id was not found',
      );
      return;
    }
    await JsonResponse.ok(request, {'ok': true, 'message': 'Property updated successfully'});
  }

  Future<void> delete(HttpRequest request, String id) async {
    final deleted = await _service.deleteProperty(id);
    if (!deleted) {
      await JsonResponse.error(
        request,
        status: HttpStatus.notFound,
        code: 'property_not_found',
        message: 'Property with id $id was not found',
      );
      return;
    }
    await JsonResponse.ok(request, {'ok': true, 'message': 'Property deleted successfully'});
  }
}
