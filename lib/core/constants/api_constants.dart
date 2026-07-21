/// Backend endpoints and network configuration.
///
/// `API_BASE_URL` can be overridden at build time:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:3000`
abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://chat-app-api-ayhv.onrender.com',
  );

  static const String refreshPath = '/auth/refresh';

  static const Duration connectTimeout = Duration(seconds: 15);

  /// Generous because the backend runs on a free tier that cold-starts:
  /// the first request after idle can take close to a minute.
  static const Duration receiveTimeout = Duration(seconds: 60);
}
