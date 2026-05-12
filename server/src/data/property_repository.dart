import 'dart:convert';
import 'dart:io';

import '../models/property.dart';

abstract class PropertyRepository {
  Future<List<Map<String, dynamic>>> getAll();
  Future<void> add(Map<String, dynamic> property);
  Future<bool> update(String id, Map<String, dynamic> property);
  Future<bool> remove(String id);
}

class FilePropertyRepository implements PropertyRepository {
  FilePropertyRepository._(this._dbFile);

  final File _dbFile;
  List<Map<String, dynamic>>? _cache;
  DateTime? _cacheUpdatedAt;
  static const Duration _cacheDuration = Duration(seconds: 10);

  static Future<FilePropertyRepository> create(String path) async {
    final dbFile = File(path);
    final dataDir = dbFile.parent;
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    if (!dbFile.existsSync()) {
      dbFile.writeAsStringSync(jsonEncode(Property.seed()));
    }
    return FilePropertyRepository._(dbFile);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    if (_cache != null && _cacheUpdatedAt != null) {
      if (DateTime.now().difference(_cacheUpdatedAt!) < _cacheDuration) {
        return _cache!;
      }
    }

    final fileData = jsonDecode(await _dbFile.readAsString());
    final mapped = List<Map<String, dynamic>>.from(fileData as List<dynamic>);
    _cache = mapped;
    _cacheUpdatedAt = DateTime.now();
    return mapped;
  }

  @override
  Future<void> add(Map<String, dynamic> property) async {
    await _update((list) {
      list.add(property);
      return true;
    });
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> property) async {
    return _update((list) {
      final index = list.indexWhere((entry) => entry['id'] == id);
      if (index == -1) {
        return false;
      }
      list[index] = property;
      return true;
    });
  }

  @override
  Future<bool> remove(String id) async {
    return _update((list) {
      final initialLength = list.length;
      list.removeWhere((entry) => entry['id'] == id);
      return list.length != initialLength;
    });
  }

  Future<bool> _update(bool Function(List<Map<String, dynamic>> list) updater) async {
    final current = List<Map<String, dynamic>>.from(await getAll());
    final didUpdate = updater(current);
    if (!didUpdate) {
      return false;
    }

    await _dbFile.writeAsString(jsonEncode(current));
    _cache = current;
    _cacheUpdatedAt = DateTime.now();
    return true;
  }
}
