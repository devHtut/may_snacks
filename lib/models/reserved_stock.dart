class ReservedStock {
  final String id;
  final String orderId;
  final String productId;
  final String? batchId;
  final int quantity;
  final String status; // 'active', 'fulfilled', 'released'
  final DateTime createdAt;

  ReservedStock({
    required this.id,
    required this.orderId,
    required this.productId,
    this.batchId,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isFulfilled => status == 'fulfilled';
  bool get isReleased => status == 'released';

  factory ReservedStock.fromJson(Map<String, dynamic> json) {
    return ReservedStock(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      batchId: json['batch_id'] as String?,
      quantity: json['quantity'] as int,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'batch_id': batchId,
      'quantity': quantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReservedStock copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? batchId,
    int? quantity,
    String? status,
    DateTime? createdAt,
  }) {
    return ReservedStock(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
