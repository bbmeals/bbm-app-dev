import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cart_item.dart';


Future<String> sendCartItemToServer({
  required String userId,
  required String restaurantId,
  required String itemId,
  required int quantity,
  required double priceSnapshot,
  required Map<String, String> customization,
}) async {


  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  final url = Uri.parse('$baseUrl/cart/$userId/cart');

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
  final url = Uri.parse('$baseUrl/cart/$userId/cart');

  try {
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      // Expecting the response to be a JSON list of cart items
      final List<dynamic> data = jsonDecode(response.body);
      print('Successfully fetched cart items');

      // Convert each JSON object into a CartItem instance
      // final cartItems = data.map((item) => CartItem.fromJson(item)).toList();
      // return cartItems;
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
  print(cartItemId);
  final url = Uri.parse('$baseUrl/cart/$userId/cart/$cartItemId');

  // If quantity is 0, we send 0 so the server can treat it as a removal request.
  final payload = {
    "quantity": quantity <= 0 ? 0 : quantity,
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


