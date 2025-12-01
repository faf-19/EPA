/// API constants for the application
class ApiConstants {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  
  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String registerEndpoint = '/auth/register';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

