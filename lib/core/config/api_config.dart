class ApiConfig {
  const ApiConfig._();

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String _legacyBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_apiBaseUrl.isNotEmpty) return _apiBaseUrl;
    if (_legacyBaseUrl.isNotEmpty) return _legacyBaseUrl;
    return 'http://localhost:8080';
  }
}
