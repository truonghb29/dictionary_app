// Test script to verify word operations
import 'dart:convert';
import 'dart:io';

void main() async {
  print('Testing Dictionary App Backend API');
  
  const String baseUrl = 'http://127.0.0.1:3001/api';
  final client = HttpClient();
  
  // Test 1: Check if server is running
  try {
    final request = await client.getUrl(Uri.parse('$baseUrl/health'));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Server Health: ${response.statusCode}');
    print('Response: $responseBody');
  } catch (e) {
    print('❌ Server not reachable: $e');
    client.close();
    return;
  }
  
  // Test 2: Try to register a test user
  final registerData = {
    'email': 'test@example.com',
    'password': 'password123'
  };
  
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl/auth/register'));
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(registerData));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Register Response: ${response.statusCode}');
    print('Register Body: $responseBody');
  } catch (e) {
    print('❌ Register error: $e');
  }
  
  // Test 3: Try to login
  String? token;
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(registerData));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Login Response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final loginData = jsonDecode(responseBody);
      token = loginData['token'];
      print('Token: $token');
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
  
  if (token == null) {
    print('❌ No token available, cannot test word operations');
    client.close();
    return;
  }
  
  // Test 4: Add a word
  final wordData = {
    'term': 'test word',
    'translations': {'vietnamese': 'từ thử nghiệm', 'french': 'mot de test'},
    'example': 'This is a test word'
  };
  
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl/user/words'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $token');
    request.write(jsonEncode(wordData));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Add Word Response: ${response.statusCode}');
    print('Add Word Body: $responseBody');
  } catch (e) {
    print('❌ Add word error: $e');
  }
  
  // Test 5: Get words
  try {
    final request = await client.getUrl(Uri.parse('$baseUrl/user/words'));
    request.headers.set('Authorization', 'Bearer $token');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Get Words Response: ${response.statusCode}');
    print('Get Words Body: $responseBody');
  } catch (e) {
    print('❌ Get words error: $e');
  }
  
  // Test 6: Delete the word
  try {
    final request = await client.deleteUrl(Uri.parse('$baseUrl/user/words/test%20word'));
    request.headers.set('Authorization', 'Bearer $token');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('✅ Delete Word Response: ${response.statusCode}');
    print('Delete Word Body: $responseBody');
  } catch (e) {
    print('❌ Delete word error: $e');
  }
  
  client.close();
  print('\n🎉 Test completed!');
}
