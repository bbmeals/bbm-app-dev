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

      // To save the document ID:
      await storage.write(key: 'userId', value: data['user']['id']);
      await storage.write(key: 'username', value: data['user']['name']);
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


/// The address is stored as a key-value pair (with `type` as the key).
Future<Map<String, dynamic>?> addAddressOnServer({
  required String userId,
  String? apt,
  required String street,
  required String city,
  required String pin,
  required String type, // e.g., "home", "office", etc.
}) async {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/users/$userId/address');

  final payload = {
    if (apt != null) 'apt': apt,
    'street': street,
    'city': city,
    'pin': pin,
    'type': type,
  };

  try {
    print('Sending address data: $payload');
    final response = await http.post(
      url,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Address added successfully');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data);
      return data;
    } else {
      print('Failed to add address on server: ${response.body}');
      return null;
    }
  } catch (error) {
    print('An error occurred while adding address: $error');
    return null;
  }
}

/// Assumes addresses are stored as a key-value pair in the user's document.
Future<Map<String, dynamic>?> fetchAddressesFromServer(String userId) async {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/users/$userId/addresses');

  try {
    print('Fetching addresses for user: $userId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Addresses fetched successfully');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data);
      return data;
    } else {
      print('Failed to fetch addresses: ${response.body}');
      return null;
    }
  } catch (error) {
    print('An error occurred while fetching addresses: $error');
    return null;
  }
}

Future<bool> checkUserExists(String phone) async {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/users/checkuser');

  final response = await http.post(
    url,
    body: jsonEncode({'phone': phone}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['exists'] as bool;
  } else {
    throw Exception('Failed to check user existence');
  }
}


