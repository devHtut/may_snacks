class StockBatch {
  final String id;
  final String productId;
  final String batchNumber;
  final int quantity;
  final int initialQuantity;
  final DateTime expiryDate;
  final DateTime receivedDate;
  final DateTime createdAt;

  StockBatch({
    required this.id,
    required this.productId,
    required this.batchNumber,
    required this.quantity,
    required this.initialQuantity,
    required this.expiryDate,
    required this.receivedDate,
    required this.createdAt,
  });

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.isBefore(today);
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }

  bool get isExpiringSoon {
    return !isExpired && daysUntilExpiry <= 30;
  }

  factory StockBatch.fromJson(Map<String, dynamic> json) {
    return StockBatch(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      batchNumber: json['batch_number'] as String,
      quantity: json['quantity'] as int,
      initialQuantity: json['initial_quantity'] as int,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      receivedDate: DateTime.parse(json['received_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'batch_number': batchNumber,
      'quantity': quantity,
      'initial_quantity': initialQuantity,
      'expiry_date': expiryDate.toIso8601String().substring(0, 10),
      'received_date': receivedDate.toIso8601String().substring(0, 10),
      'created_at': createdAt.toIso8601String(),
    };
  }

  StockBatch copyWith({
    String? id,
    String? productId,
    String? batchNumber,
    int? quantity,
    int? initialQuantity,
    DateTime? expiryDate,
    DateTime? receivedDate,
    DateTime? createdAt,
  }) {
    return StockBatch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      expiryDate: expiryDate ?? this.expiryDate,
      receivedDate: receivedDate ?? this.receivedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockBatch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
