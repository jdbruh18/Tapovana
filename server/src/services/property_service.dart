import '../core/request_validator.dart';
import '../data/property_repository.dart';

class PropertyService {
  PropertyService(this._repository);

  final PropertyRepository _repository;

  Future<List<Map<String, dynamic>>> listProperties() {
    return _repository.getAll();
  }

  Future<void> createProperty(Map<String, dynamic> payload) async {
    RequestValidator.validatePropertyPayload(payload);
    await _repository.add(payload);
  }

  Future<bool> updateProperty(String id, Map<String, dynamic> payload) async {
    RequestValidator.validatePropertyPayload(payload);
    RequestValidator.validatePathAndPayloadId(id, payload);
    return _repository.update(id, payload);
  }

  Future<bool> deleteProperty(String id) async {
    return _repository.remove(id);
  }
}
