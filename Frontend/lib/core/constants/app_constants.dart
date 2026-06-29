// Application-wide constants

class AppConstants {
  // App Info
  static const String appName = 'CarWash Pro';
  static const String appVersion = '1.0.0';

  // Timeout durations
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 800);

  // Keys for SharedPreferences
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userPreferencesKey = 'user_preferences';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Service pricing
  static const double minServicePrice = 100.0;
  static const double maxServicePrice = 5000.0;

  // Rating
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // Pagination
  static const int pageSize = 20;
  static const int initialPage = 1;

  // Location
  static const double defaultLatitude = 28.7041;
  static const double defaultLongitude = 77.1025;
  static const double locationUpdateInterval = 10.0; // seconds
  // Mock login credentials
  static const String adminEmail = 'admin@example.com';
  static const String vendorEmail = 'vendor@example.com';
  static const String customerEmail = 'customer@example.com';
  static const String defaultPassword = 'password123';
}
