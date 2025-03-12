// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../services/cart_services.dart'; // For getCartItemsFromServer

class CartItem {
  final String id;
  final String title;
  final double price;
  final String image;
  int quantity;
  final String description;
  final String allergens;
  final String nutritionInfo;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
    required this.description,
    required this.allergens,
    required this.nutritionInfo,
  });

  double get totalPrice => price * quantity;
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem({
    required String productId,
    required String title,
    required double price,
    required String image,
    required String description,
    required String allergens,
    required String nutritionInfo,
    required String docId, // new parameter for the document id from the server
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
            (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          image: existingItem.image,
          quantity: existingItem.quantity + 1,
          description: existingItem.description,
          allergens: existingItem.allergens,
          nutritionInfo: existingItem.nutritionInfo,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
            () => CartItem(
          id: docId, // use the document id returned from the server
          title: title,
          price: price,
          image: image,
          quantity: 1,
          description: description,
          allergens: allergens,
          nutritionInfo: nutritionInfo,
        ),
      );
    }
    notifyListeners();
  }


  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // void updateQuantity(String productId, int newQuantity) {
  //   print("rying update");
  //   print(_items.map((key, value) => MapEntry(key, {
  //     'id': value.id,
  //     'title': value.title,
  //     'price': value.price,
  //     'image': value.image,
  //     'quantity': value.quantity,
  //     'description': value.description,
  //     'allergens': value.allergens,
  //     'nutritionInfo': value.nutritionInfo,
  //   })));
  //   print(productId);
  //   if (_items.containsKey(productId)) {
  //     print('Contains');
  //     _items.update(
  //       productId,
  //           (existingItem) => CartItem(
  //         id: existingItem.id,
  //         title: existingItem.title,
  //         price: existingItem.price,
  //         image: existingItem.image,
  //         description: existingItem.description,
  //         allergens: existingItem.allergens,
  //         nutritionInfo: existingItem.nutritionInfo,
  //         quantity: newQuantity, // Update only the quantity
  //       ),
  //     );
  //     print(_items);
  //     notifyListeners();
  //   }
  // }

  void updateQuantity(String productId, int newQuantity) {
    print("Trying update");

    // Print the mapped items to check keys
    print(_items.map((key, value) => MapEntry(key, {
      'id': value.id,
      'title': value.title,
      'price': value.price,
      'image': value.image,
      'quantity': value.quantity,
      'description': value.description,
      'allergens': value.allergens,
      'nutritionInfo': value.nutritionInfo,
    })));

    print('Product ID: $productId');

    // Find the key in _items where value.id == productId
    final keyToUpdate = _items.keys.firstWhere(
          (key) => _items[key]!.id == productId, // Match document ID
      orElse: () => '',
    );

    if (keyToUpdate.isNotEmpty) {
      if (newQuantity <= 0) {
        // 🔥 Remove item if new quantity is 0 or less
        print('Removing item: $productId');
        _items.remove(keyToUpdate);

        // Remove from database (assuming Firestore)
        // removeItemFromDatabase(productId);
      } else {
        // 🔄 Update quantity normally
        _items.update(
          keyToUpdate,
              (existingItem) => CartItem(
            id: existingItem.id,
            title: existingItem.title,
            price: existingItem.price,
            image: existingItem.image,
            description: existingItem.description,
            allergens: existingItem.allergens,
            nutritionInfo: existingItem.nutritionInfo,
            quantity: newQuantity, // Update only the quantity
          ),
        );
      }

      print(_items);
      notifyListeners();
    } else {
      print('Product ID not found in _items!');
    }
  }



  void decrementItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
            (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          image: existingItem.image,
          quantity: existingItem.quantity - 1,
          description: existingItem.description,
          allergens: existingItem.allergens,
          nutritionInfo: existingItem.nutritionInfo,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  int getItemQuantity(String productId) {
    if (!_items.containsKey(productId)) {
      return 0;
    }
    return _items[productId]!.quantity;
  }

  /// Loads the cart items from the backend endpoint and updates the provider.
  Future<void> loadCartItems(String userId) async {
    try {
      final rawData = await getCartItemsFromServer(userId);
      _items = {}; // Clear any existing items

      for (var cartDoc in rawData) {
        // Normalize each field from Firestore's wrapped format.
        Map<String, dynamic> normalized = {};
        cartDoc.forEach((key, value) {
          normalized[key] = _extractValue(value);
        });

        // If menu details were merged on the backend, normalize them.
        Map<String, dynamic>? menuDetails;
        if (normalized.containsKey('menuDetails') && normalized['menuDetails'] != null) {
          menuDetails = _normalizeMap(normalized['menuDetails']);
        }

        // Use menuDetails if available to build UI fields.
        String title = 'Unknown Item';
        if (menuDetails != null) {
          if (menuDetails.containsKey('name')) {
            title = menuDetails['name'];
          } else if (menuDetails.containsKey('Name')) {
            title = menuDetails['Name'];
          }
        } else {
          title = normalized['itemId'] ?? 'Unknown Item';
        }

        // Price: check for "price" or "Price"
        double price = 0;
        if (menuDetails != null && (menuDetails.containsKey('price') || menuDetails.containsKey('Price'))) {
          var p = menuDetails['price'] ?? menuDetails['Price'];
          if (p is int) {
            price = p.toDouble();
          } else if (p is double) {
            price = p;
          }
        } else {
          // Fallback: use the priceSnapshot stored in the cart.
          var snapshot = normalized['priceSnapshot'];
          if (snapshot is double) {
            price = snapshot;
          } else if (snapshot is int) {
            price = snapshot.toDouble();
          }
        }

        // Image: using "image_url"
        String image = '';
        if (menuDetails != null && (menuDetails.containsKey('image_url') || menuDetails.containsKey('Image_url'))) {
          image = menuDetails['image_url'] ?? menuDetails['Image_url'];
        }

        // Description: check "description" or "Description"
        String description = '';
        if (menuDetails != null && (menuDetails.containsKey('description') || menuDetails.containsKey('Description'))) {
          description = menuDetails['description'] ?? menuDetails['Description'];
        }

        // Allergens: from the menu details.
        String allergens = '';
        if (menuDetails != null && menuDetails.containsKey('allergens')) {
          var allergenField = menuDetails['allergens'];
          if (allergenField is List) {
            allergens = allergenField.join(', ');
          } else {
            allergens = allergenField.toString();
          }
        }

        // Nutrition: Format the nutrition map as a comma separated string.
        String nutritionInfo = '';
        if (menuDetails != null && menuDetails.containsKey('nutrition')) {
          var nutrition = menuDetails['nutrition'];
          if (nutrition is Map) {
            nutritionInfo = nutrition.entries
                .map((e) => "${e.key}: ${e.value}")
                .join(', ');
          } else {
            nutritionInfo = nutrition.toString();
          }
        }

        int quantity = 1;
        if (normalized['quantity'] is int) {
          quantity = normalized['quantity'];
        } else {
          quantity = int.tryParse(normalized['quantity'].toString()) ?? 1;
        }

        // Use itemId as the key for _items.
        String productId = normalized['id'] ?? normalized['itemId'] ?? DateTime.now().toString();

        String id = normalized['id'] ?? DateTime.now().toString();

        // Add this item to the provider.
        _items[productId] = CartItem(
          id: id,
          title: title,
          price: price,
          image: image,
          quantity: quantity,
          description: description,
          allergens: allergens,
          nutritionInfo: nutritionInfo,
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error loading cart items: $e");
    }
  }

  /// Helper function to extract underlying value from Firestore wrappers.
  dynamic _extractValue(dynamic field) {
    if (field is Map<String, dynamic>) {
      if (field.containsKey('stringValue')) return field['stringValue'];
      if (field.containsKey('integerValue'))
        return int.tryParse(field['integerValue'] ?? '') ?? field['integerValue'];
      if (field.containsKey('doubleValue')) return field['doubleValue'];
      if (field.containsKey('booleanValue')) return field['booleanValue'];
      if (field.containsKey('timestampValue')) return field['timestampValue'];
      if (field.containsKey('mapValue')) {
        return _normalizeMap(field['mapValue']['fields'] ?? {});
      }
      if (field.containsKey('arrayValue')) {
        if (field['arrayValue']['values'] is List) {
          return (field['arrayValue']['values'] as List)
              .map((e) => _extractValue(e))
              .toList();
        }
      }
    }
    return field;
  }

  /// Recursively normalize a Firestore map.
  Map<String, dynamic> _normalizeMap(Map<String, dynamic> map) {
    Map<String, dynamic> normalized = {};
    map.forEach((k, v) {
      normalized[k] = _extractValue(v);
    });
    return normalized;
  }
}
