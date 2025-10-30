class User {
  final String id;
  final String name;
  final String deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOnline;
  final String? lastKnownLocation;

  const User({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.isOnline = false,
    this.lastKnownLocation,
  });

  User copyWith({
    String? id,
    String? name,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnline,
    String? lastKnownLocation,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceId': deviceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isOnline': isOnline,
      'lastKnownLocation': lastKnownLocation,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      deviceId: json['deviceId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isOnline: json['isOnline'] ?? false,
      lastKnownLocation: json['lastKnownLocation'],
    );
  }
}