import 'dart:io';

class ApiConfig {
  /// Override with: flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://127.0.0.1:3000';
  }

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
