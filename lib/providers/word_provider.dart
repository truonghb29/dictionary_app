import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../data/sample_data.dart';
import '../services/auth_service.dart';
import '../services/user_word_service.dart';

class WordProvider with ChangeNotifier {
  // List to store all words
  List<Word> _words = [];
  static const String _prefsKey = 'dictionary_words';
  final AuthService _authService = AuthService();
  final UserWordService _userWordService = UserWordService();
  bool _isLoading = false;
  String? _errorMessage;

  // Getter for loading state
  bool get isLoading => _isLoading;
  
  // Getter for error message
  String? get errorMessage => _errorMessage;

  WordProvider() {
    // Initialize AuthService and then load saved words
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _authService.initialize();
    await loadWords();
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
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('DEBUG: Loading words - Is logged in: ${_authService.isUserLoggedIn}');
      
      // If user is logged in, load from UserWordService
      if (_authService.isUserLoggedIn) {
        debugPrint('DEBUG: Loading words from cloud storage...');
        _words = await _userWordService.getUserWords();
        debugPrint('DEBUG: Loaded ${_words.length} words from cloud');

        // If no data in cloud yet but we have local data, upload it
        if (_words.isEmpty) {
          debugPrint('DEBUG: No words in cloud, checking local storage...');
          await _loadWordsFromLocal();

          // If we have local words, upload them to the cloud
          if (_words.isNotEmpty) {
            debugPrint('DEBUG: Uploading ${_words.length} local words to cloud...');
            await _userWordService.saveAllWords(_words);
          }
        }
      } else {
        debugPrint('DEBUG: Not logged in, loading from local storage...');
        // Not logged in, load from SharedPreferences
        await _loadWordsFromLocal();
      }
      
      debugPrint('DEBUG: Final word count: ${_words.length}');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('DEBUG: Error loading words: $e');
      // If error occurs, load sample data or local data
      await _loadWordsFromLocal();
      if (_words.isEmpty) {
        debugPrint('DEBUG: Loading sample data...');
        _loadSampleData();
      }
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
              return Word.fromJson(item);
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
          _words.map((word) => word.toJson()).toList();

      final String wordsJson = jsonEncode(encodableList);
      await prefs.setString(_prefsKey, wordsJson);

      // If logged in, also save to cloud
      if (_authService.isUserLoggedIn) {
        await _userWordService.saveAllWords(_words);
      }
    } catch (e) {
      debugPrint('Error saving words: $e');
    }
  }

  // Method to add a new word to the list
  Future<void> addWord(Word word) async {
    try {
      debugPrint('DEBUG: Adding word: ${word.term} - Is logged in: ${_authService.isUserLoggedIn}');
      
      // If logged in, add to cloud first
      if (_authService.isUserLoggedIn) {
        debugPrint('DEBUG: Adding word to cloud storage...');
        final addedWord = await _userWordService.addWord(
          term: word.term,
          translations: word.translations,
          example: word.example,
        );
        _words.add(addedWord);
        debugPrint('DEBUG: Word added to cloud successfully');
      } else {
        debugPrint('DEBUG: Adding word to local storage only');
        _words.add(word);
      }

      await _saveWords();
      debugPrint('DEBUG: Word saved successfully. Total words: ${_words.length}');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('DEBUG: Error adding word: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Method to update an existing word
  Future<void> updateWord(int index, Word updatedWord) async {
    if (index >= 0 && index < _words.length) {
      try {
        // If logged in, update in cloud first
        if (_authService.isUserLoggedIn) {
          final cloudUpdatedWord = await _userWordService.updateWord(
            term: updatedWord.term,
            translations: updatedWord.translations,
            example: updatedWord.example,
          );
          _words[index] = cloudUpdatedWord;
        } else {
          _words[index] = updatedWord;
        }

        await _saveWords();
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        debugPrint('Error updating word: $e');
        notifyListeners();
        rethrow;
      }
    }
  }

  // Method to delete a word
  Future<void> deleteWord(int index) async {
    if (index >= 0 && index < _words.length) {
      final wordToDelete = _words[index];
      debugPrint('DEBUG: Deleting word: ${wordToDelete.term} at index $index - Is logged in: ${_authService.isUserLoggedIn}');
      
      try {
        // If logged in, delete from cloud first
        if (_authService.isUserLoggedIn) {
          debugPrint('DEBUG: Deleting word from cloud storage...');
          await _userWordService.deleteWord(wordToDelete.term);
          debugPrint('DEBUG: Word deleted from cloud successfully');
        }

        _words.removeAt(index);
        await _saveWords();
        debugPrint('DEBUG: Word deleted successfully. Remaining words: ${_words.length}');
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        debugPrint('DEBUG: Error deleting word: $e');
        notifyListeners();
        rethrow;
      }
    }
  }

  // Method to find index of a word by term
  int findWordIndex(String term) {
    return _words.indexWhere((word) => word.term == term);
  }

  // Method to clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
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
