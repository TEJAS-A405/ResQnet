import 'package:beaconmesh/models/user.dart';
import 'package:beaconmesh/models/location_data.dart';

enum SosStatus { active, acknowledged, resolved }

enum SosPriority { critical, high, medium }

class SosAlert {
  final String id;
  final User sender;
  final String message;
  final SosPriority priority;
  final SosStatus status;
  final LocationData? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> acknowledgedBy;
  final int broadcastRadius;
  final Map<String, dynamic> metadata;

  const SosAlert({
    required this.id,
    required this.sender,
    required this.message,
    this.priority = SosPriority.critical,
    this.status = SosStatus.active,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.acknowledgedBy = const [],
    this.broadcastRadius = -1, // -1 means broadcast to all nodes
    this.metadata = const {},
  });

  SosAlert copyWith({
    String? id,
    User? sender,
    String? message,
    SosPriority? priority,
    SosStatus? status,
    LocationData? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? acknowledgedBy,
    int? broadcastRadius,
    Map<String, dynamic>? metadata,
  }) {
    return SosAlert(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      broadcastRadius: broadcastRadius ?? this.broadcastRadius,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'message': message,
      'priority': priority.name,
      'status': status.name,
      'location': location?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'acknowledgedBy': acknowledgedBy,
      'broadcastRadius': broadcastRadius,
      'metadata': metadata,
    };
  }

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    return SosAlert(
      id: json['id'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      message: json['message'] ?? '',
      priority: SosPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => SosPriority.critical,
      ),
      status: SosStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SosStatus.active,
      ),
      location: json['location'] != null ? LocationData.fromJson(json['location']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      acknowledgedBy: List<String>.from(json['acknowledgedBy'] ?? []),
      broadcastRadius: json['broadcastRadius'] ?? -1,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  String get displayStatus {
    switch (status) {
      case SosStatus.active:
        return 'ACTIVE';
      case SosStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case SosStatus.resolved:
        return 'RESOLVED';
    }
  }

  String get displayPriority {
    switch (priority) {
      case SosPriority.critical:
        return 'CRITICAL';
      case SosPriority.high:
        return 'HIGH';
      case SosPriority.medium:
        return 'MEDIUM';
    }
  }
}