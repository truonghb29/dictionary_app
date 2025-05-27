// Config file for backend API settings
class ApiConfig {
  // Development settings
  static const String _localBaseUrl = 'http://127.0.0.1:3001/api'; // Changed for iOS simulator compatibility
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3001/api';

  // Production settings (replace with your actual production URL)
  static const String _productionBaseUrl = 'https://your-app.herokuapp.com/api';

  // Current environment
  static const bool _isDevelopment = true; // Set to false for production

  // Get the appropriate base URL based on environment and platform
  static String get baseUrl {
    if (_isDevelopment) {
      // For development, you can manually switch between local and Android emulator
      return _localBaseUrl; // Change to _androidEmulatorUrl if using Android emulator
    } else {
      return _productionBaseUrl;
    }
  }

  // API endpoints
  static const String healthEndpoint = '/health';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String wordsEndpoint = '/dictionary/words';
  static const String userWordsEndpoint = '/user/words';
  
  // Admin endpoints
  static const String adminDashboardEndpoint = '/admin/dashboard';
  static const String adminAnalyticsEndpoint = '/admin/analytics';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminAnalyticsSaveEndpoint = '/admin/analytics/save';

  // Request timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}
