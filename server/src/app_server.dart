import 'dart:io';

import 'data/property_repository.dart';
import 'handlers/property_handler.dart';
import 'handlers/proxy_handler.dart';
import 'integrations/integrations_config.dart';
import 'routing/app_router.dart';

class AppServer {
  AppServer({
    InternetAddress? host,
    this.port = 8080,
  }) : _host = host ?? InternetAddress.loopbackIPv4;

  final InternetAddress _host;
  final int port;

  Future<void> start() async {
    final repository = await FilePropertyRepository.create('server/data/properties.json');
    final integrations = IntegrationsConfig.fromEnvironment();

    final router = AppRouter(
      propertyHandler: PropertyHandler(repository),
      proxyHandler: ProxyHandler(),
      integrations: integrations,
    );

    final server = await HttpServer.bind(_host, port);
    stdout.writeln('Property server running at http://localhost:$port');

    await for (final request in server) {
      await router.route(request);
    }
  }
}
