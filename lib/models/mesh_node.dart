import 'package:beaconmesh/models/user.dart';

enum NodeStatus { connected, disconnected, weak }

class MeshNode {
  final String nodeId;
  final User user;
  final NodeStatus status;
  final int hopCount;
  final double signalStrength;
  final DateTime lastSeen;
  final List<String> connectedNodes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeshNode({
    required this.nodeId,
    required this.user,
    required this.status,
    this.hopCount = 0,
    this.signalStrength = 0.0,
    required this.lastSeen,
    this.connectedNodes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  MeshNode copyWith({
    String? nodeId,
    User? user,
    NodeStatus? status,
    int? hopCount,
    double? signalStrength,
    DateTime? lastSeen,
    List<String>? connectedNodes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeshNode(
      nodeId: nodeId ?? this.nodeId,
      user: user ?? this.user,
      status: status ?? this.status,
      hopCount: hopCount ?? this.hopCount,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      connectedNodes: connectedNodes ?? this.connectedNodes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId,
      'user': user.toJson(),
      'status': status.name,
      'hopCount': hopCount,
      'signalStrength': signalStrength,
      'lastSeen': lastSeen.toIso8601String(),
      'connectedNodes': connectedNodes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MeshNode.fromJson(Map<String, dynamic> json) {
    return MeshNode(
      nodeId: json['nodeId'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      status: NodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NodeStatus.disconnected,
      ),
      hopCount: json['hopCount'] ?? 0,
      signalStrength: json['signalStrength']?.toDouble() ?? 0.0,
      lastSeen: DateTime.parse(json['lastSeen'] ?? DateTime.now().toIso8601String()),
      connectedNodes: List<String>.from(json['connectedNodes'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isOnline => status == NodeStatus.connected;
  
  String get displayStatus {
    switch (status) {
      case NodeStatus.connected:
        return 'Connected';
      case NodeStatus.weak:
        return 'Weak Signal';
      case NodeStatus.disconnected:
        return 'Disconnected';
    }
  }
}