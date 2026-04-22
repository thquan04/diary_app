class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.address,
    required this.notes,
    required this.createdAt,
    this.estimatedDelivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items:
      (json['items'] as List?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'address': address,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String foodId;
  final String foodName;
  final int quantity;
  final double price;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'price': price,
    };
  }
}
