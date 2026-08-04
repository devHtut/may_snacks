class AuditLog {
  final String id;
  final String? actorId;
  final String action;
  final String description;
  final DateTime createdAt;
  
  // UI Display Helper
  final String? actorName;

  AuditLog({
    required this.id,
    this.actorId,
    required this.action,
    required this.description,
    required this.createdAt,
    this.actorName,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      actorId: json['actor_id'] as String?,
      action: json['action'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      actorName: json['profiles']?['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_id': actorId,
      'action': action,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
