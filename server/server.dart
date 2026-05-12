import 'src/app_server.dart';

Future<void> main() async {
  final appServer = AppServer();
  await appServer.start();
}
