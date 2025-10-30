import 'dart:io';
import 'package:beaconmesh/models/user.dart';
import 'package:beaconmesh/services/storage_service.dart';

class UserService {
  static User? _currentUser;
  static const String _defaultUserName = 'ResQ User';

  static Future<User> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;

    // Try to load existing user from storage
    final userData = await StorageService.loadObject(StorageService.userKey);
    if (userData != null) {
      _currentUser = User.fromJson(userData);
      return _currentUser!;
    }

    // Create new user with device-based ID
    final deviceId = await _generateDeviceId();
    final now = DateTime.now();
    _currentUser = User(
      id: 'user_${deviceId}_${now.millisecondsSinceEpoch}',
      name: _defaultUserName,
      deviceId: deviceId,
      createdAt: now,
      updatedAt: now,
      isOnline: true,
    );

    await _saveCurrentUser();
    return _currentUser!;
  }

  static Future<void> updateUserProfile(String name) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );

    await _saveCurrentUser();
  }

  static Future<void> updateUserStatus(bool isOnline, [String? location]) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      isOnline: isOnline,
      lastKnownLocation: location ?? _currentUser!.lastKnownLocation,
      updatedAt: DateTime.now(),
    );

    await _saveCurrentUser();
  }

  static Future<void> _saveCurrentUser() async {
    if (_currentUser != null) {
      await StorageService.saveObject(StorageService.userKey, _currentUser!.toJson());
    }
  }

  static Future<String> _generateDeviceId() async {
    try {
      // Use platform info to generate a unique device identifier
      final platform = Platform.operatingSystem;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 10000).toString().padLeft(4, '0');
      return '${platform}_${random}';
    } catch (e) {
      // Fallback to timestamp-based ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static void clearCurrentUser() {
    _currentUser = null;
    StorageService.clearData(StorageService.userKey);
  }

  static User? get currentUser => _currentUser;
  static String get displayName => _currentUser?.name ?? _defaultUserName;
  static String get deviceId => _currentUser?.deviceId ?? 'unknown';
  static bool get isOnline => _currentUser?.isOnline ?? false;
}