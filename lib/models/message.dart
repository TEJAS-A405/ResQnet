import 'package:beaconmesh/models/user.dart';
import 'package:beaconmesh/models/location_data.dart';

enum MessageStatus { sending, sent, delivered, failed }

enum MessageType { text, sos }

class Message {
  final String id;
  final String content;
  final User sender;
  final String? recipientId;
  final MessageType type;
  final MessageStatus status;
  final LocationData? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int hopCount;
  final List<String> routePath;

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    this.recipientId,
    required this.type,
    this.status = MessageStatus.sending,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.hopCount = 0,
    this.routePath = const [],
  });

  Message copyWith({
    String? id,
    String? content,
    User? sender,
    String? recipientId,
    MessageType? type,
    MessageStatus? status,
    LocationData? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? hopCount,
    List<String>? routePath,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hopCount: hopCount ?? this.hopCount,
      routePath: routePath ?? this.routePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toJson(),
      'recipientId': recipientId,
      'type': type.name,
      'status': status.name,
      'location': location?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hopCount': hopCount,
      'routePath': routePath,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      recipientId: json['recipientId'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sending,
      ),
      location: json['location'] != null ? LocationData.fromJson(json['location']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      hopCount: json['hopCount'] ?? 0,
      routePath: List<String>.from(json['routePath'] ?? []),
    );
  }
}