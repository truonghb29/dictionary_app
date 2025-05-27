import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final AuthService _authService = AuthService();

  String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.token}',
    };
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.adminDashboardEndpoint}'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch dashboard stats');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalytics({String period = '7d'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.adminAnalyticsEndpoint}?period=$period'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch analytics');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all users
  Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.adminUsersEndpoint}?page=$page&limit=$limit'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update user role
  Future<Map<String, dynamic>> updateUserRole(String userId, String role) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiConfig.adminUsersEndpoint}/$userId/role'),
        headers: _getAuthHeaders(),
        body: jsonEncode({'role': role}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update user role');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiConfig.adminUsersEndpoint}/$userId'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Save analytics
  Future<Map<String, dynamic>> saveAnalytics() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.adminAnalyticsSaveEndpoint}'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to save analytics');
      }
    } catch (e) {
      rethrow;
    }
  }
}
