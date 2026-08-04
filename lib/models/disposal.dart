enum DisposalStatus {
  pending,
  approved,
  rejected;

  String get key {
    switch (this) {
      case DisposalStatus.pending:
        return 'pending';
      case DisposalStatus.approved:
        return 'approved';
      case DisposalStatus.rejected:
        return 'rejected';
    }
  }

  static DisposalStatus fromKey(String key) {
    switch (key) {
      case 'approved':
        return DisposalStatus.approved;
      case 'rejected':
        return DisposalStatus.rejected;
      case 'pending':
      default:
        return DisposalStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case DisposalStatus.pending:
        return 'Pending';
      case DisposalStatus.approved:
        return 'Approved';
      case DisposalStatus.rejected:
        return 'Rejected';
    }
  }
}

class DisposalRequest {
  final String id;
  final String productId;
  final String batchId;
  final int quantity;
  final String reason;
  final DisposalStatus status;
  final String? requestedBy;
  final DateTime createdAt;

  // UI display helpers
  final String? productName;
  final String? batchNumber;
  final String? requesterName;

  DisposalRequest({
    required this.id,
    required this.productId,
    required this.batchId,
    required this.quantity,
    required this.reason,
    required this.status,
    this.requestedBy,
    required this.createdAt,
    this.productName,
    this.batchNumber,
    this.requesterName,
  });

  factory DisposalRequest.fromJson(Map<String, dynamic> json) {
    return DisposalRequest(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      batchId: json['batch_id'] as String,
      quantity: json['quantity'] as int,
      reason: json['reason'] as String,
      status: DisposalStatus.fromKey(json['status'] as String),
      requestedBy: json['requested_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      productName: json['products']?['name'] as String?,
      batchNumber: json['batches']?['batch_number'] as String?,
      requesterName: json['profiles']?['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'batch_id': batchId,
      'quantity': quantity,
      'reason': reason,
      'status': status.key,
      'requested_by': requestedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
