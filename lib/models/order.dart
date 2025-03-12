class OrderItem {
  final String itemId;
  final int quantity;
  final double price;
  final Map<String, dynamic> customization;

  OrderItem({
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.customization,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    itemId: json['itemId'] as String,
    quantity: json['quantity'] as int,
    price: (json['price'] as num).toDouble(),
    customization: json['customization'] as Map<String, dynamic>,
  );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
    'price': price,
    'customization': customization,
  };
}

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String deliveryType;
  final DateTime? scheduledTime;
  final String deliveryAddress;
  final String paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryType,
    this.scheduledTime,
    required this.deliveryAddress,
    required this.paymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['userId'] as String,
    restaurantId: json['restaurantId'] as String,
    items: (json['items'] as List)
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: (json['total'] as num).toDouble(),
    status: json['status'] as String,
    deliveryType: json['deliveryType'] as String,
    scheduledTime: json['scheduledTime'] != null
        ? DateTime.parse(json['scheduledTime'] as String)
        : null,
    deliveryAddress: json['deliveryAddress'] as String,
    paymentId: json['paymentId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'restaurantId': restaurantId,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'status': status,
    'deliveryType': deliveryType,
    'scheduledTime': scheduledTime?.toIso8601String(),
    'deliveryAddress': deliveryAddress,
    'paymentId': paymentId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
