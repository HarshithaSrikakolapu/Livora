class AppConfig {
  static const String appName = 'Livora';
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';
  
  // API Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxFavorites = 10;
}
