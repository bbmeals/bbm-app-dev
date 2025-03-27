// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../services/cart_services.dart'; // For getCartItemsFromServer

class CartValue {
  final String docId;
  final String title;
  final double price;
  final String image;
  int quantity;
  final String description;
  final String allergens;
  final String nutritionInfo;
  final String menuItemId;
  final String category;

  CartValue({
    required this.docId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
    required this.description,
    required this.allergens,
    required this.nutritionInfo,
    required this.menuItemId,
    required this.category,
  });

  double get totalPrice => price * quantity;
}

class CartProvider with ChangeNotifier {
  Map<String, CartValue> _items = {};

  // Add a field for the order note.
  String _orderNote = '';


  // Getter for the order note.
  String get orderNote => _orderNote;

  // Setter to update the order note.
  void setOrderNote(String note) {
    _orderNote = note;
    notifyListeners();
  }


  Map<String, CartValue> get items => {..._items};

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
    required String docId,
    required String menuItemId,
    required String category,
  }) {
    print(docId);
    print(menuItemId);
    _items[docId] = CartValue(
      docId: docId,
      title: title,
      price: price,
      image: image,
      quantity: 1,
      description: description,
      allergens: allergens,
      nutritionInfo: nutritionInfo,
      menuItemId: menuItemId,
      category: category,
    );
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity <= 0) {
        _items.remove(productId);
      } else {
        final existingItem = _items[productId]!;
        _items[productId] = CartValue(
          docId: existingItem.docId,
          title: existingItem.title,
          price: existingItem.price,
          image: existingItem.image,
          description: existingItem.description,
          allergens: existingItem.allergens,
          nutritionInfo: existingItem.nutritionInfo,
          quantity: newQuantity,
          menuItemId: existingItem.menuItemId,
          category: existingItem.category,
        );
      }
      notifyListeners();
    } else {
      print('Product ID not found in _items!');
    }
  }

  void decrementItem(String productId) {
    if (!_items.containsKey(productId)) return;

    final existingItem = _items[productId]!;

    if (existingItem.quantity > 1) {
      _items[productId] = CartValue(
        docId: existingItem.docId,
        title: existingItem.title,
        price: existingItem.price,
        image: existingItem.image,
        description: existingItem.description,
        allergens: existingItem.allergens,
        nutritionInfo: existingItem.nutritionInfo,
        quantity: existingItem.quantity - 1,
        menuItemId: existingItem.menuItemId,
        category: existingItem.category,
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

  int getTotalQuantityByMenuItemId(String menuItemId) {
    return _items.values
        .where((item) => item.menuItemId == menuItemId)
        .fold(0, (total, item) => total + item.quantity);
  }

  List<String> getAllCategories() {
    return _items.values.map((item) => item.category).toSet().toList();
  }

  List<String> getAllMenuItems() {
    return _items.values.map((item) => item.menuItemId).toSet().toList();
  }

  Future<void> loadCartItems(String userId) async {
    try {
      final rawData = await getCartItemsFromServer(userId);
      _items = {};

      for (var cartDoc in rawData) {
        Map<String, dynamic> data = Map<String, dynamic>.from(cartDoc);

        Map<String, dynamic>? menuDetails = data['menuDetails'] != null
            ? Map<String, dynamic>.from(data['menuDetails'])
            : null;

        String title = menuDetails?['name'] ?? data['itemId'] ?? 'Unknown Item';

        double price = 0;
        if (menuDetails != null && menuDetails.containsKey('price')) {
          var p = menuDetails['price'];
          if (p is int) {
            price = p.toDouble();
          } else if (p is double) {
            price = p;
          }
        }

        String image = menuDetails?['image_url'] ?? '';
        String description = menuDetails?['description'] ?? '';
        String category = menuDetails?['category'] ?? 'Unknown';

        String allergens = '';
        if (menuDetails != null && menuDetails.containsKey('allergens')) {
          var allergenField = menuDetails['allergens'];
          if (allergenField is List) {
            allergens = allergenField.join(', ');
          } else {
            allergens = allergenField.toString();
          }
        }

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

        int quantity = data['quantity'] is int ? data['quantity'] : int.tryParse(data['quantity'].toString()) ?? 1;
        String productId = data['id'];

        _items[productId] = CartValue(
          docId: productId,
          title: title,
          price: price,
          image: image,
          quantity: quantity,
          description: description,
          allergens: allergens,
          nutritionInfo: nutritionInfo,
          menuItemId: menuDetails?['id'],
          category: category,
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error loading cart items: $e");
    }
  }
}