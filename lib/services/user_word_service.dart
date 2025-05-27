import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../config/api_config.dart';

class UserWordService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all words for the user
  Future<List<Word>> getUserWords() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/words'),
        headers: headers,
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> wordsData = data['words'];
          return wordsData.map((wordJson) => Word(
            term: wordJson['term'],
            translations: Map<String, String>.from(wordJson['translations']),
            example: wordJson['example'] ?? '',
            createdAt: wordJson['createdAt'] != null 
                ? DateTime.parse(wordJson['createdAt']) 
                : null,
            updatedAt: wordJson['updatedAt'] != null 
                ? DateTime.parse(wordJson['updatedAt']) 
                : null,
          )).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get words');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get words');
      }
    } catch (e) {
      throw Exception('Error getting words: $e');
    }
  }

  // Add a new word
  Future<Word> addWord({
    required String term,
    required Map<String, String> translations,
    String? example,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'term': term,
        'translations': translations,
        'example': example ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/user/words'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final wordData = data['word'];
          return Word(
            term: wordData['term'],
            translations: Map<String, String>.from(wordData['translations']),
            example: wordData['example'] ?? '',
            createdAt: wordData['createdAt'] != null 
                ? DateTime.parse(wordData['createdAt']) 
                : null,
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to add word');
        }
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid word data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add word');
      }
    } catch (e) {
      throw Exception('Error adding word: $e');
    }
  }

  // Update a word
  Future<Word> updateWord({
    required String term,
    required Map<String, String> translations,
    String? example,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'translations': translations,
        'example': example ?? '',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/user/words/${Uri.encodeComponent(term)}'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final wordData = data['word'];
          return Word(
            term: wordData['term'],
            translations: Map<String, String>.from(wordData['translations']),
            example: wordData['example'] ?? '',
            updatedAt: wordData['updatedAt'] != null 
                ? DateTime.parse(wordData['updatedAt']) 
                : null,
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to update word');
        }
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid word data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Word not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update word');
      }
    } catch (e) {
      throw Exception('Error updating word: $e');
    }
  }

  // Delete a word
  Future<void> deleteWord(String term) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/user/words/${Uri.encodeComponent(term)}'),
        headers: headers,
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete word');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Word not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete word');
      }
    } catch (e) {
      throw Exception('Error deleting word: $e');
    }
  }

  // Bulk save words (replace all words)
  Future<void> saveAllWords(List<Word> words) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'words': words.map((word) => {
          'term': word.term,
          'translations': word.translations,
          'example': word.example ?? '',
          'createdAt': word.createdAt?.toIso8601String(),
        }).toList(),
      };

      final response = await http.put(
        Uri.parse('$baseUrl/user/words'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to save words');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save words');
      }
    } catch (e) {
      throw Exception('Error saving words: $e');
    }
  }
}
