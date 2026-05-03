import 'dart:convert';
import 'dart:io';

class Property {
  String id;
  String name;
  String imageAsset;
  double rating;
  double distanceKm;
  bool verified;
  Map<String, double> prices;
  List<String> nextStarts;

  Property({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.rating,
    required this.distanceKm,
    required this.verified,
    required this.prices,
    required this.nextStarts,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageAsset': imageAsset,
    'rating': rating,
    'distanceKm': distanceKm,
    'verified': verified,
    'prices': prices,
    'nextStarts': nextStarts,
  };

  static Property fromJson(Map<String, dynamic> j) => Property(
    id: j['id'] as String,
    name: j['name'] as String,
    imageAsset: j['imageAsset'] as String,
    rating: (j['rating'] as num).toDouble(),
    distanceKm: (j['distanceKm'] as num).toDouble(),
    verified: j['verified'] as bool,
    prices: (j['prices'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
    nextStarts: (j['nextStarts'] as List).map((e) => e.toString()).toList(),
  );
}

// Whitelist allowed domains for proxy
const Set<String> allowedProxyHosts = {
  'flutter.github.io',
  'github.io',
};

// Simple in-memory cache for properties
List<Map<String, dynamic>>? _cachedProperties;
DateTime? _cacheLastUpdated;
const Duration cacheDuration = Duration(seconds: 10);

void main() async {
  final dataDir = Directory('server/data');
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }
  final dbFile = File('server/data/properties.json');
  if (!dbFile.existsSync()) {
    dbFile.writeAsStringSync(jsonEncode(_seed()));
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  stdout.writeln('Property server running at http://localhost:8080');

  await for (final req in server) {
    // CORS
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    req.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      continue;
    }

    final path = req.uri.path;
    try {
      if (path == '/properties' && req.method == 'GET') {
        final list = await _getProperties(dbFile);
        _json(req, list);
      } else if (path == '/properties' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);
        await _updateProperties(dbFile, (list) {
          list.add(data);
          return list;
        });
        _json(req, {'ok': true});
      } else if (path.startsWith('/properties/') && req.method == 'PUT') {
        final id = path.split('/').last;
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        await _updateProperties(dbFile, (list) {
          final idx = list.indexWhere((e) => e['id'] == id);
          if (idx != -1) {
            list[idx] = data;
          }
          return list;
        });
        _json(req, {'ok': true});
      } else if (path.startsWith('/properties/') && req.method == 'DELETE') {
        final id = path.split('/').last;
        await _updateProperties(dbFile, (list) {
          list.removeWhere((e) => e['id'] == id);
          return list;
        });
        _json(req, {'ok': true});
      } else if (path == '/proxy' && req.method == 'GET') {
        final url = req.uri.queryParameters['url'];
        if (url == null || url.isEmpty) {
          _json(req, {'error': 'missing_url'}, status: HttpStatus.badRequest);
        } else {
          final uri = Uri.tryParse(url);
          if (uri == null || !allowedProxyHosts.contains(uri.host)) {
            _json(req, {'error': 'forbidden_host'}, status: HttpStatus.forbidden);
          } else {
            await _proxyImage(req, uri);
          }
        }
      } else {
        _json(req, {'error': 'not_found'}, status: HttpStatus.notFound);
      }
    } catch (e) {
      stderr.writeln('Error handling request: $e');
      _json(req, {'error': 'internal_server_error'}, status: HttpStatus.internalServerError);
    }
  }
}

Future<List<dynamic>> _getProperties(File dbFile) async {
  if (_cachedProperties != null && _cacheLastUpdated != null) {
    if (DateTime.now().difference(_cacheLastUpdated!) < cacheDuration) {
      return _cachedProperties!;
    }
  }
  final list = jsonDecode(await dbFile.readAsString());
  _cachedProperties = List<Map<String, dynamic>>.from(list);
  _cacheLastUpdated = DateTime.now();
  return list;
}

Future<void> _updateProperties(File dbFile, List<dynamic> Function(List<dynamic>) updater) async {
  final list = List<dynamic>.from(jsonDecode(await dbFile.readAsString()));
  final updatedList = updater(list);
  await dbFile.writeAsString(jsonEncode(updatedList));
  _cachedProperties = List<Map<String, dynamic>>.from(updatedList);
  _cacheLastUpdated = DateTime.now();
}

Future<void> _proxyImage(HttpRequest req, Uri uri) async {
  try {
    final client = HttpClient();
    client.userAgent = 'TapovanaProxy/1.0';
    // Enable strict SSL validation (removed badCertificateCallback)
    final request = await client.getUrl(uri);
    request.headers.add('Accept', 'image/*');
    request.headers.add('Connection', 'close');
    final externalResp = await request.close();
    if (externalResp.statusCode != HttpStatus.ok) {
      _json(req, {'error': 'bad status', 'status': externalResp.statusCode}, status: HttpStatus.badGateway);
    } else {
      final bytes = await externalResp.reduce((a, b) => a + b);
      req.response.statusCode = HttpStatus.ok;
      final ct = externalResp.headers.contentType ?? ContentType('application', 'octet-stream');
      req.response.headers.contentType = ct;
      req.response.headers.set('Cache-Control', 'public, max-age=3600');
      req.response.add(bytes);
      await req.response.close();
    }
    client.close();
  } catch (e) {
    _json(req, {'error': 'proxy_failed', 'message': e.toString()}, status: HttpStatus.internalServerError);
  }
}

void _json(HttpRequest req, Object data, {int status = HttpStatus.ok}) {
  req.response.statusCode = status;
  req.response.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
  req.response.write(jsonEncode(data));
  req.response.close();
}

List<Map<String, dynamic>> _seed() => [
  Property(
    id: 'p1',
    name: 'Homestay Thachi',
    imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
    rating: 4.6,
    distanceKm: 0.8,
    verified: true,
    prices: {'30m': 99, '1h': 149, '2h': 249, '3h': 329, '4h': 389},
    nextStarts: const ['11:00', '11:30', '12:00', '12:30'],
  ).toJson(),
  Property(
    id: 'p2',
    name: 'Village Room, Jibhi',
    imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/puffin.jpg',
    rating: 4.4,
    distanceKm: 1.2,
    verified: true,
    prices: {'30m': 89, '1h': 139, '2h': 229, '3h': 309, '4h': 369},
    nextStarts: const ['10:30', '11:00', '11:30'],
  ).toJson(),
  Property(
    id: 'p3',
    name: 'Bir Hill Pod',
    imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/flamingos.jpg',
    rating: 4.5,
    distanceKm: 2.7,
    verified: false,
    prices: {'30m': 79, '1h': 129, '2h': 219, '3h': 289, '4h': 349},
    nextStarts: const ['12:00', '12:30', '13:00'],
  ).toJson(),
];
