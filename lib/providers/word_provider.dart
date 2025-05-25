import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../data/sample_data.dart';
import '../services/auth_service.dart';

class WordProvider with ChangeNotifier {
  // List to store all words
  List<Word> _words = [];
  static const String _prefsKey = 'dictionary_words';
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Getter for loading state
  bool get isLoading => _isLoading;

  WordProvider() {
    // Load saved words when initialized
    loadWords();
  }

  // Getter to provide a copy of the words list sorted alphabetically
  List<Word> get words {
    final sortedWords = [..._words];
    sortedWords.sort(
      (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
    );
    return sortedWords;
  }

  // Check if user is logged in
  bool get isUserLoggedIn => _authService.isUserLoggedIn;

  // Load words based on login status (cloud storage if logged in, SharedPreferences otherwise)
  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    try {
      // If user is logged in, load from AuthService
      if (_authService.isUserLoggedIn) {
        _words = await _authService.loadWords();

        // If no data in cloud yet but we have local data, upload it
        if (_words.isEmpty) {
          await _loadWordsFromLocal();

          // If we have local words, upload them to AuthService
          if (_words.isNotEmpty) {
            await _authService.saveWords(_words);
          }
        }
      } else {
        // Not logged in, load from SharedPreferences
        await _loadWordsFromLocal();
      }
    } catch (e) {
      debugPrint('Error loading words: $e');
      // If error occurs, load sample data
      _loadSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to load words from SharedPreferences
  Future<void> _loadWordsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? wordsJson = prefs.getString(_prefsKey);

      if (wordsJson != null) {
        final List<dynamic> decodedList = jsonDecode(wordsJson);
        _words =
            decodedList.map((item) {
              return Word(
                term: item['term'],
                translations: Map<String, String>.from(item['translations']),
                example: item['example'],
              );
            }).toList();
      } else {
        // If no saved data, load sample data on first run
        _loadSampleData();
      }
    } catch (e) {
      debugPrint('Error loading words from SharedPreferences: $e');
      // If error occurs, load sample data
      _loadSampleData();
    }
  }

  // Load sample data
  void _loadSampleData() {
    _words = SampleData.getSampleWords();
    _saveWords();
    notifyListeners();
  }

  // Save words to storage (cloud storage if logged in, SharedPreferences otherwise)
  Future<void> _saveWords() async {
    try {
      // Save to SharedPreferences (always maintain local copy)
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodableList =
          _words.map((word) {
            return {
              'term': word.term,
              'translations': word.translations,
              'example': word.example,
            };
          }).toList();

      final String wordsJson = jsonEncode(encodableList);
      await prefs.setString(_prefsKey, wordsJson);

      // If logged in, also save to cloud
      if (_authService.isUserLoggedIn) {
        await _authService.saveWords(_words);
      }
    } catch (e) {
      debugPrint('Error saving words: $e');
    }
  }

  // Method to add a new word to the list
  Future<void> addWord(Word word) async {
    _words.add(word);

    // If logged in, add to cloud and then save locally
    if (_authService.isUserLoggedIn) {
      try {
        await _authService.addWord(word);
      } catch (e) {
        debugPrint('Error adding word to cloud: $e');
      }
    }

    await _saveWords();
    notifyListeners();
  }

  // Method to update an existing word
  Future<void> updateWord(int index, Word updatedWord) async {
    if (index >= 0 && index < _words.length) {
      _words[index] = updatedWord;
      await _saveWords();
      notifyListeners();
    }
  }

  // Method to delete a word
  Future<void> deleteWord(int index) async {
    if (index >= 0 && index < _words.length) {
      final wordToDelete = _words[index];
      _words.removeAt(index);

      // If logged in, delete from cloud
      if (_authService.isUserLoggedIn) {
        try {
          await _authService.deleteWord(wordToDelete);
        } catch (e) {
          debugPrint('Error deleting word from cloud: $e');
        }
      }

      await _saveWords();
      notifyListeners();
    }
  }

  // Method to find index of a word by term
  int findWordIndex(String term) {
    return _words.indexWhere((word) => word.term == term);
  }

  // Sign out method
  Future<void> signOut() async {
    await _authService.signOut();
    // Reload words from local storage after sign out
    await _loadWordsFromLocal();
    notifyListeners();
  }

  // Get all unique first letters for grouping
  List<String> get uniqueFirstLetters {
    final letterSet = <String>{};
    for (var word in words) {
      if (word.term.isNotEmpty) {
        letterSet.add(word.term[0].toUpperCase());
      }
    }
    final letters = letterSet.toList();
    letters.sort();
    return letters;
  }

  // Get words starting with a specific letter
  List<Word> getWordsStartingWith(String letter) {
    return words
        .where(
          (word) =>
              word.term.isNotEmpty &&
              word.term[0].toUpperCase() == letter.toUpperCase(),
        )
        .toList();
  }

  // Method to search for words
  List<Word> searchWord(String query) {
    if (query.isEmpty) {
      return words;
    }
    return _words.where((word) {
      // Check if query matches term
      if (word.term.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      // Check if query matches any translation
      for (var translation in word.translations.values) {
        if (translation.toLowerCase().contains(query.toLowerCase())) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}
