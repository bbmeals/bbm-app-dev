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
  DateTime? scheduledTime,
}) async {
  final url = Uri.parse('$baseUrl/orders/$userId/place');

  List<Map<String, dynamic>> formattedItems = items.map((item) {
    return {
      "mapValue": {
        "fields": item.map((key, value) {
          return MapEntry(key, _convertToFirestoreFormat(value));
        })
      }
    };
  }).toList();

  final now = DateTime.now().toUtc();

  final payload = {
    "items": {
      "arrayValue": {"values": formattedItems}
    },
    "delivery_type": {"stringValue": deliveryType},
    "delivery_address": {"stringValue": deliveryAddress},
    "total": {"integerValue": total.toInt()},
    "userId": {"stringValue": userId},
    "created_at": {"timestampValue": now.toIso8601String()},  // ✅ Correct format
    "updated_at": {"timestampValue": now.toIso8601String()},  // ✅ Correct format
    if (scheduledTime != null)
      "scheduled_time": {"timestampValue": scheduledTime.toIso8601String()},
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

// Helper function to convert values to Firestore format
Map<String, dynamic> _convertToFirestoreFormat(dynamic value) {
  if (value is String) return {"stringValue": value};
  if (value is int) return {"integerValue": value};
  if (value is double) return {"doubleValue": value};
  if (value is bool) return {"booleanValue": value};
  if (value is DateTime) return {"timestampValue": value.toIso8601String()};
  if (value is List) {
    return {
      "arrayValue": {
        "values": value.map((v) => _convertToFirestoreFormat(v)).toList()
      }
    };
  }
  if (value is Map<String, dynamic>) {
    return {
      "mapValue": {
        "fields": value.map((k, v) => MapEntry(k, _convertToFirestoreFormat(v)))
      }
    };
  }
  return {}; // Default case
}
