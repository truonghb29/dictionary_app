import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../config/api_config.dart';

class AuthService {
  // Use the centralized API configuration
  static String get baseUrl => ApiConfig.baseUrl;

  String? _token;
  String? _userId;
  Map<String, dynamic>? _userProfile;

  // Get current user ID
  String? get userId => _userId;

  // Get current user profile
  Map<String, dynamic>? get currentUser => _userProfile;

  // Check if user is logged in
  bool get isUserLoggedIn => _token != null && _userId != null;

  // Initialize service by loading stored token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');

    // If we have a token, try to load user profile
    if (_token != null && _userId != null) {
      await _loadUserProfile();
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await getUserProfile();
    } catch (e) {
      print('Error loading user profile: $e');
      // If profile loading fails, clear auth data
      await signOut();
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['user']['_id'];
        _userProfile = data['user'];

        // Store token and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _userId!);

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['user']['_id'];
        _userProfile = data['user'];

        // Store token and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _userId!);

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _userProfile = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get authorization headers
  Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  // Save words to MongoDB
  Future<void> saveWords(List<Word> words) async {
    if (!isUserLoggedIn) return;

    try {
      final wordsData =
          words
              .map(
                (word) => {
                  'term': word.term,
                  'translations': word.translations,
                  'example': word.example,
                },
              )
              .toList();

      final response = await http.put(
        Uri.parse('$baseUrl/dictionary/words'),
        headers: _getAuthHeaders(),
        body: jsonEncode({'words': wordsData}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to save words');
      }
    } catch (e) {
      print('Error saving words to MongoDB: $e');
      rethrow;
    }
  }

  // Load words from MongoDB
  Future<List<Word>> loadWords() async {
    if (!isUserLoggedIn) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dictionary/words'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> wordsData = data['words'] ?? [];

        return wordsData.map((wordData) {
          return Word(
            term: wordData['term'],
            translations: Map<String, String>.from(wordData['translations']),
            example: wordData['example'],
          );
        }).toList();
      } else {
        print('Error loading words: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error loading words from MongoDB: $e');
      return [];
    }
  }

  // Add a single word
  Future<void> addWord(Word word) async {
    if (!isUserLoggedIn) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dictionary/words'),
        headers: _getAuthHeaders(),
        body: jsonEncode({
          'term': word.term,
          'translations': word.translations,
          'example': word.example,
        }),
      );

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add word');
      }
    } catch (e) {
      print('Error adding word to MongoDB: $e');
      rethrow;
    }
  }

  // Delete a word
  Future<void> deleteWord(Word word) async {
    if (!isUserLoggedIn) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/dictionary/words'),
        headers: _getAuthHeaders(),
        body: jsonEncode({'term': word.term}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete word');
      }
    } catch (e) {
      print('Error deleting word from MongoDB: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isUserLoggedIn) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}
