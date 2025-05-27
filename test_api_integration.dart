#!/usr/bin/env dart

// Simple test script to verify the backend API integration
// Run this with: dart test_api_integration.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:3001/api';

Future<void> main() async {
  print('🧪 Testing Dictionary App API Integration');
  print('=========================================\n');

  try {
    // Test 1: Health check
    await testHealthCheck();
    
    // Test 2: User registration
    final authData = await testUserRegistration();
    if (authData == null) return;
    
    // Test 3: User login
    final token = await testUserLogin(authData);
    if (token == null) return;
    
    // Test 4: Add a word
    await testAddWord(token);
    
    // Test 5: Get user words
    await testGetUserWords(token);
    
    // Test 6: Update a word
    await testUpdateWord(token);
    
    // Test 7: Delete a word
    await testDeleteWord(token);
    
    print('\n✅ All tests passed! API integration is working correctly.');
    
  } catch (e) {
    print('\n❌ Test failed with error: $e');
    exit(1);
  }
}

Future<void> testHealthCheck() async {
  print('1️⃣ Testing health check...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      print('   ✅ Backend is running');
    } else {
      throw Exception('Health check failed: ${response.statusCode}');
    }
  } catch (e) {
    print('   ❌ Backend is not running. Please start the backend server first.');
    throw e;
  }
}

Future<Map<String, dynamic>?> testUserRegistration() async {
  print('2️⃣ Testing user registration...');
  final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
  final testPassword = 'testpassword123';
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('   ✅ User registration successful');
      return {'email': testEmail, 'password': testPassword};
    } else {
      print('   ❌ Registration failed: ${response.body}');
      return null;
    }
  } catch (e) {
    print('   ❌ Registration error: $e');
    return null;
  }
}

Future<String?> testUserLogin(Map<String, dynamic> authData) async {
  print('3️⃣ Testing user login...');
  final testEmail = authData['email'];
  final testPassword = authData['password'];
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('   ✅ User login successful');
      return data['token'];
    } else {
      print('   ❌ Login failed: ${response.body}');
      return null;
    }
  } catch (e) {
    print('   ❌ Login error: $e');
    return null;
  }
}

Future<void> testAddWord(String token) async {
  print('4️⃣ Testing add word...');
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/user/words'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'term': 'hello',
        'translations': {
          'spanish': 'hola',
          'french': 'bonjour',
        },
        'example': 'Hello, how are you?',
      }),
    );
    
    if (response.statusCode == 201) {
      print('   ✅ Word added successfully');
    } else {
      print('   ❌ Add word failed: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Add word error: $e');
  }
}

Future<void> testGetUserWords(String token) async {
  print('5️⃣ Testing get user words...');
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/words'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final words = data['words'] as List;
      print('   ✅ Retrieved ${words.length} words');
    } else {
      print('   ❌ Get words failed: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Get words error: $e');
  }
}

Future<void> testUpdateWord(String token) async {
  print('6️⃣ Testing update word...');
  
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/user/words/hello'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'translations': {
          'spanish': 'hola',
          'french': 'bonjour',
          'german': 'hallo',
        },
        'example': 'Hello, how are you doing today?',
      }),
    );
    
    if (response.statusCode == 200) {
      print('   ✅ Word updated successfully');
    } else {
      print('   ❌ Update word failed: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Update word error: $e');
  }
}

Future<void> testDeleteWord(String token) async {
  print('7️⃣ Testing delete word...');
  
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/words/hello'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      print('   ✅ Word deleted successfully');
    } else {
      print('   ❌ Delete word failed: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Delete word error: $e');
  }
}
