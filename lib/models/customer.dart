enum CustomerStatus {
  pending,
  approved,
  rejected;

  String get key {
    switch (this) {
      case CustomerStatus.pending:
        return 'pending';
      case CustomerStatus.approved:
        return 'approved';
      case CustomerStatus.rejected:
        return 'rejected';
    }
  }

  static CustomerStatus fromKey(String key) {
    switch (key) {
      case 'approved':
        return CustomerStatus.approved;
      case 'rejected':
        return CustomerStatus.rejected;
      case 'pending':
      default:
        return CustomerStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case CustomerStatus.pending:
        return 'Pending Approval';
      case CustomerStatus.approved:
        return 'Approved';
      case CustomerStatus.rejected:
        return 'Rejected';
    }
  }
}

class Customer {
  final String id;
  final String name;
  final String region;
  final String township;
  final String? address;
  final String phone;
  final CustomerStatus status;
  final String? createdBy;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.region,
    required this.township,
    this.address,
    required this.phone,
    required this.status,
    this.createdBy,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String? ?? 'Yangon Region',
      township: json['township'] as String? ?? 'Kamayut',
      address: json['address'] as String?,
      phone: json['phone'] as String? ?? '0912345678',
      status: CustomerStatus.fromKey(json['status'] as String? ?? 'approved'),
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'township': township,
      'address': address,
      'phone': phone,
      'status': status.key,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? region,
    String? township,
    String? address,
    String? phone,
    CustomerStatus? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      township: township ?? this.township,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
