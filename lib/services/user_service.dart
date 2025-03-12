import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<Map<String, dynamic>?> createUserOnServer({
  required String phone,
  String? name,
  String? email,
}) async {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/users/adduser');

  final payload = {
    'phone': phone,
    if (name != null) 'name': name,
    if (email != null) 'email': email,

  };


  try {
    print('Sending user data: $payload');
    final response = await http.post(
      url,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('User created successfully');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data);
      print(data['user']['id']);
      // To save the document ID:
      await storage.write(key: 'userId', value: data['user']['id']);
      return data;
    } else {
      print('Failed to create user on server: ${response.body}');
      return null;
    }
  } catch (error) {
    print('An error occurred while creating user: $error');
    return null;
  }
}

