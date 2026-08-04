enum UserRole {
  admin,
  warehouseManager,
  salesStaff;

  String get key {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.warehouseManager:
        return 'warehouse_manager';
      case UserRole.salesStaff:
        return 'sales_staff';
    }
  }

  static UserRole fromKey(String key) {
    switch (key) {
      case 'admin':
        return UserRole.admin;
      case 'warehouse_manager':
        return UserRole.warehouseManager;
      case 'sales_staff':
      default:
        return UserRole.salesStaff;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.warehouseManager:
        return 'Warehouse Manager';
      case UserRole.salesStaff:
        return 'Sales Staff';
    }
  }
}

class UserProfile {
  final String id;
  final String email;
  final UserRole role;
  final String displayName;
  final bool requiresPasswordReset;
  final bool isActive;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    required this.requiresPasswordReset,
    this.isActive = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromKey(json['role'] as String),
      displayName: json['display_name'] as String? ?? '',
      requiresPasswordReset: json['requires_password_reset'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.key,
      'display_name': displayName,
      'requires_password_reset': requiresPasswordReset,
      'is_active': isActive,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? displayName,
    bool? requiresPasswordReset,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      requiresPasswordReset: requiresPasswordReset ?? this.requiresPasswordReset,
      isActive: isActive ?? this.isActive,
    );
  }
}
