import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

Future<Restaurant> fetchRestaurantData() async {
  final url = Uri.parse('http://localhost:8080/restaurants/bbm');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return Restaurant.fromJson(jsonData);
  } else {
    throw Exception('Failed to load restaurant data');
  }
}
