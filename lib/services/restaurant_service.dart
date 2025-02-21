import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bbm_backend_dev/models/restaurant.dart';

class RestaurantService {
  static const String baseUrl =
      'http://localhost:8080'; // Change for production

  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/restaurants/'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
