class PhysicalAudit {
  final String id;
  final String productId;
  final String batchId;
  final int systemQuantity;
  final int physicalQuantity;
  final int discrepancy;
  final String? notes;
  final String? auditedBy;
  final DateTime createdAt;

  // UI display helpers
  final String? productName;
  final String? batchNumber;
  final String? auditorName;

  PhysicalAudit({
    required this.id,
    required this.productId,
    required this.batchId,
    required this.systemQuantity,
    required this.physicalQuantity,
    required this.discrepancy,
    this.notes,
    this.auditedBy,
    required this.createdAt,
    this.productName,
    this.batchNumber,
    this.auditorName,
  });

  factory PhysicalAudit.fromJson(Map<String, dynamic> json) {
    return PhysicalAudit(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      batchId: json['batch_id'] as String,
      systemQuantity: json['system_quantity'] as int,
      physicalQuantity: json['physical_quantity'] as int,
      discrepancy: json['discrepancy'] as int,
      notes: json['notes'] as String?,
      auditedBy: json['audited_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      productName: json['products']?['name'] as String?,
      batchNumber: json['batches']?['batch_number'] as String?,
      auditorName: json['profiles']?['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'batch_id': batchId,
      'system_quantity': systemQuantity,
      'physical_quantity': physicalQuantity,
      'discrepancy': discrepancy,
      'notes': notes,
      'audited_by': auditedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
