class CartItem {
  final String id;
  final String userId;
  final String restaurantId;
  final String itemId;
  final int quantity;
  final double priceSnapshot;
  final Map<String, String> customization;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.itemId,
    required this.quantity,
    required this.priceSnapshot,
    required this.customization,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    restaurantId: json['restaurantId'] ?? '',
    itemId: json['itemId'] ?? '',
    quantity: json['quantity'] ?? 0,
    priceSnapshot: (json['priceSnapshot'] ?? 0).toDouble(),
    customization: json['customization'] != null
        ? Map<String, String>.from(json['customization'])
        : {},
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'restaurantId': restaurantId,
    'itemId': itemId,
    'quantity': quantity,
    'priceSnapshot': priceSnapshot,
    'customization': customization,
    'createdAt': createdAt.toIso8601String(),
  };
}
