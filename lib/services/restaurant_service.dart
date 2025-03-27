import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Restaurant> fetchRestaurantData() async {
  try {

    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
    final url = Uri.parse('$baseUrl/restaurants/bbm');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print(jsonData);
      return Restaurant.fromJson(jsonData);
    } else {
      throw Exception('Failed to load restaurant data');
    }
  } catch (e) {
    print('Error fetching restaurant data: $e');
    throw e; // rethrowing the exception if further handling is needed
  }
}

