enum OrderStatus {
  pending,
  packed,
  delivered;

  String get key {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.packed:
        return 'packed';
      case OrderStatus.delivered:
        return 'delivered';
    }
  }

  static OrderStatus fromKey(String key) {
    switch (key) {
      case 'packed':
        return OrderStatus.packed;
      case 'delivered':
        return OrderStatus.delivered;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  
  // Display Helpers
  final String? productName;
  final double? productPrice;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.productPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      productName: json['products']?['name'] as String?,
      productPrice: (json['products']?['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String customerName;
  final OrderStatus status;
  final String? salesStaffId;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    this.salesStaffId,
    required this.createdAt,
    required this.items,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.quantity * (item.productPrice ?? 0.0)));
  }

  factory Order.fromJson(Map<String, dynamic> json, [List<dynamic>? itemsList]) {
    final parsedItems = itemsList != null
        ? itemsList.map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>)).toList()
        : (json['order_items'] as List?)
            ?.map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>))
            .toList() ?? <OrderItem>[];

    return Order(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      status: OrderStatus.fromKey(json['status'] as String),
      salesStaffId: json['sales_staff_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'status': status.key,
      'sales_staff_id': salesStaffId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? customerName,
    OrderStatus? status,
    String? salesStaffId,
    DateTime? createdAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      salesStaffId: salesStaffId ?? this.salesStaffId,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
