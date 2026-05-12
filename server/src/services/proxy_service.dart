import 'dart:io';

class ProxyResult {
  ProxyResult({
    required this.statusCode,
    this.bytes,
    this.contentType,
    this.errorCode,
    this.message,
  });

  final int statusCode;
  final List<int>? bytes;
  final ContentType? contentType;
  final String? errorCode;
  final String? message;

  bool get isSuccess => bytes != null;
}

class ProxyService {
  static const Set<String> allowedProxyHosts = {'flutter.github.io', 'github.io'};

  Future<ProxyResult> fetchImage(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !allowedProxyHosts.contains(uri.host)) {
      return ProxyResult(
        statusCode: HttpStatus.forbidden,
        errorCode: 'forbidden_host',
        message: 'Host is not allowed for proxy requests',
      );
    }

    final client = HttpClient()..userAgent = 'TapovanaProxy/1.0';
    try {
      final request = await client.getUrl(uri);
      request.headers.add('Accept', 'image/*');
      request.headers.add('Connection', 'close');

      final externalResponse = await request.close();
      if (externalResponse.statusCode != HttpStatus.ok) {
        return ProxyResult(
          statusCode: HttpStatus.badGateway,
          errorCode: 'bad_gateway',
          message: 'Upstream image host returned status ${externalResponse.statusCode}',
        );
      }

      final bytesBuilder = BytesBuilder(copy: false);
      await for (final chunk in externalResponse) {
        bytesBuilder.add(chunk);
      }
      final bytes = bytesBuilder.toBytes();

      return ProxyResult(
        statusCode: HttpStatus.ok,
        bytes: bytes,
        contentType: externalResponse.headers.contentType ?? ContentType.binary,
      );
    } catch (error) {
      stderr.writeln('Proxy fetch failed: $error');
      return ProxyResult(
        statusCode: HttpStatus.internalServerError,
        errorCode: 'proxy_failed',
        message: 'Failed to proxy requested image',
      );
    } finally {
      client.close(force: true);
    }
  }
}
