/// API constants for the application
class ApiConstants {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'http://196.188.240.103:4032/api/';
  
  // Authentication endpoints
  static const String loginEndpoint = '/customer-accounts/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String registerEndpoint = '/customer-accounts';
  static const String verifyOtpEndpoint = '/customer-accounts/verify-otp';
  static const String resendOtpEndpoint = '/customer-accounts/resend-otp';
  
  // Location endpoints (full URLs using baseUrl)
  static const String regionsEndpoint = '${baseUrl}regions';
  // zones endpoint can be queried as '${zonesByRegionEndpoint}/region/{regionId}'
  static const String zonesByRegionEndpoint = '${baseUrl}zones/region';
  // woredas endpoint can be queried as '${woredasByLocationEndpoint}/location/{zoneId}'
  static const String woredasByLocationEndpoint = '${baseUrl}woredas/location';
  
  // Pollution categories endpoint
  static const String pollutionCategoriesEndpoint = '${baseUrl}pollution-categories';
  
  // Complaints endpoint
  static const String complaintsEndpoint = '${baseUrl}complaints';
  static String complaintByIdEndpoint(String complaintId) => '${baseUrl}complaints/$complaintId';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String officesEndpoint = '${baseUrl}epa-office-locations';
  
  // Awareness endpoint
  static const String awarenessEndpoint = '${baseUrl}awareness';

  // Sound areas endpoint
  static const String soundAreasEndpoint = '${baseUrl}sound-areas';
}

