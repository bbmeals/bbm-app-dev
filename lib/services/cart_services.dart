import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<String> sendCartItemToServer({
  required String userId,
  required String restaurantId,
  required String itemId,
  required int quantity,
  required double priceSnapshot,
  required Map<String, String> customization,
}) async {
  print('Sending cart item data with the following parameters:');
  print('userId: $userId');
  print('restaurantId: $restaurantId');
  print('itemId: $itemId');
  print('quantity: $quantity');
  print('priceSnapshot: $priceSnapshot');
  print('customization: $customization');

  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/users/$userId/cart');

  final payload = {
    'userId': userId,
    'restaurantId': restaurantId,
    'itemId': itemId,
    'quantity': quantity,
    'priceSnapshot': priceSnapshot,
    'customization': customization,
  };

  try {
    final response = await http.post(
      url,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Assuming your server returns the new document id under the key 'id'
      final documentId = responseData['id'] as String;
      print('Document id received: $documentId');
      return documentId;
    } else {
      throw Exception('Failed to add cart item on server: ${response.body}');
    }
  } catch (error) {
    print('An error occurred: $error');
    rethrow;
  }
}


Future<List<dynamic>> getCartItemsFromServer(String userId) async {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  final url = Uri.parse('$baseUrl/users/$userId/cart');
  try {
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      // Decode the JSON response which is expected to be a list of cart items.
      final data = jsonDecode(response.body);
      print('Successfully fetched cart items');
      return data;
    } else {
      print('Failed to fetch cart items: ${response.body}');
      return [];
    }
  } catch (error) {
    print('An error occurred while fetching cart items: $error');
    return [];
  }
}

// Update Quantity
Future<bool> updateCartItemQuantity({
  required String userId,
  required String cartItemId,
  required int quantity,
}) async {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/users/$userId/cart/$cartItemId');

  // If quantity is 0, indicate that the item should be removed
  final payload = {
    "quantity": quantity <= 0 ? null : {"integerValue": quantity.toString()}
  };

  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print(quantity <= 0
          ? 'Cart item $cartItemId removed successfully'
          : 'Cart item $cartItemId updated to quantity $quantity');
      return true;
    } else {
      print('Failed to update cart item: ${response.body}');
      return false;
    }
  } catch (error) {
    print('Error updating cart item quantity: $error');
    return false;
  }
}

