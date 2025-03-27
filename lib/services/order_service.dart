import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Replace with your actual backend URL.
final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

Future<Map<String, dynamic>> placeOrder({
  required String userId,
  required List<Map<String, dynamic>> items,
  required double total,
  required String deliveryType,
  required String deliveryAddress,
  String? note,
  DateTime? scheduledTime,
  required restaurantId,
  required payment_id
}) async {
  final url = Uri.parse('$baseUrl/orders/$userId/place');
  final now = DateTime.now().toUtc().toIso8601String();


  final payload = {
    "items": items,
    "delivery_type": deliveryType,
    "delivery_address": deliveryAddress,
    "total": total.toInt(),
    "userId": userId,
    "created_at": now,
    "updated_at": now,
    "note":note,
    "restaurantId":restaurantId,
    "payment_id":payment_id,
    if (scheduledTime != null)
      "scheduled_time": scheduledTime.toIso8601String(),
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to place order: ${response.body}');
  }
}

Future<List<dynamic>> getUserOrders(String userId) async {
  final url = Uri.parse('$baseUrl/orders/$userId');

  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );


  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception('Failed to fetch orders: ${response.body}');
  }
}




