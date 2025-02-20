// Create a new file: lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';

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

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem({
    required String productId,
    required String title,
    required double price,
    required String image,
    required String description,
    required String allergens,
    required String nutritionInfo,
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
          id: DateTime.now().toString(),
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
}