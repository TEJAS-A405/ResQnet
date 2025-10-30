import 'dart:async';
import 'dart:math';
import 'package:beaconmesh/models/sos_alert.dart';
import 'package:beaconmesh/models/message.dart';
import 'package:beaconmesh/services/storage_service.dart';
import 'package:beaconmesh/services/user_service.dart';
import 'package:beaconmesh/services/location_service.dart';
import 'package:beaconmesh/services/message_service.dart';

class SosService {
  static List<SosAlert> _sosAlerts = [];
  static final StreamController<List<SosAlert>> _alertsController = StreamController<List<SosAlert>>.broadcast();

  static Stream<List<SosAlert>> get alertsStream => _alertsController.stream;
  static List<SosAlert> get allAlerts => List.from(_sosAlerts);
  static List<SosAlert> get activeAlerts => _sosAlerts.where((alert) => alert.status == SosStatus.active).toList();

  static Future<void> initializeSosService() async {
    await _loadStoredAlerts();
    _notifyAlertsUpdate();
  }

  static Future<SosAlert> broadcastSosAlert({
    String? customMessage,
    SosPriority priority = SosPriority.critical,
    bool includeLocation = true,
  }) async {
    final currentUser = await UserService.getCurrentUser();
    final now = DateTime.now();
    
    // Generate unique alert ID
    final alertId = 'sos_${now.millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    
    // Get current location if available
    final location = includeLocation ? await LocationService.getCurrentLocation() : null;
    
    // Create default SOS message based on priority
    String message = customMessage ?? _getDefaultSosMessage(priority);
    if (location != null) {
      message += '\nLocation: ${location.formattedLocation}';
    }
    
    // Create SOS alert
    final sosAlert = SosAlert(
      id: alertId,
      sender: currentUser,
      message: message,
      priority: priority,
      status: SosStatus.active,
      location: location,
      createdAt: now,
      updatedAt: now,
      acknowledgedBy: [],
      broadcastRadius: -1, // Broadcast to all nodes
      metadata: {
        'auto_generated': customMessage == null,
        'device_id': currentUser.deviceId,
        'broadcast_time': now.toIso8601String(),
      },
    );

    // Add to local alerts
    _sosAlerts.add(sosAlert);
    await _saveAlerts();
    _notifyAlertsUpdate();

    // Also send as a high-priority message through mesh network
    await MessageService.sendMessage(
      '🚨 SOS ALERT: $message',
      includeLocation: includeLocation,
    );

    // Simulate alert propagation
    _simulateAlertPropagation(sosAlert);

    return sosAlert;
  }

  static Future<void> acknowledgeSosAlert(String alertId, String acknowledgedBy) async {
    final alertIndex = _sosAlerts.indexWhere((alert) => alert.id == alertId);
    if (alertIndex >= 0) {
      final alert = _sosAlerts[alertIndex];
      final updatedAcknowledgements = List<String>.from(alert.acknowledgedBy);
      
      if (!updatedAcknowledgements.contains(acknowledgedBy)) {
        updatedAcknowledgements.add(acknowledgedBy);
        
        _sosAlerts[alertIndex] = alert.copyWith(
          status: SosStatus.acknowledged,
          acknowledgedBy: updatedAcknowledgements,
          updatedAt: DateTime.now(),
        );
        
        await _saveAlerts();
        _notifyAlertsUpdate();
      }
    }
  }

  static Future<void> resolveSosAlert(String alertId) async {
    final alertIndex = _sosAlerts.indexWhere((alert) => alert.id == alertId);
    if (alertIndex >= 0) {
      _sosAlerts[alertIndex] = _sosAlerts[alertIndex].copyWith(
        status: SosStatus.resolved,
        updatedAt: DateTime.now(),
      );
      
      await _saveAlerts();
      _notifyAlertsUpdate();
    }
  }

  static Future<void> receiveExternalSosAlert(SosAlert alert) async {
    // Check if alert already exists
    final existingIndex = _sosAlerts.indexWhere((a) => a.id == alert.id);
    if (existingIndex >= 0) return;

    // Add received alert
    _sosAlerts.add(alert.copyWith(updatedAt: DateTime.now()));
    await _saveAlerts();
    _notifyAlertsUpdate();
  }

  static List<SosAlert> getAlertsByStatus(SosStatus status) {
    return _sosAlerts.where((alert) => alert.status == status).toList();
  }

  static List<SosAlert> getAlertsByPriority(SosPriority priority) {
    return _sosAlerts.where((alert) => alert.priority == priority).toList();
  }

  static List<SosAlert> getRecentAlerts({int limit = 20}) {
    final sortedAlerts = List<SosAlert>.from(_sosAlerts);
    sortedAlerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedAlerts.take(limit).toList();
  }

  static SosAlert? getAlertById(String alertId) {
    try {
      return _sosAlerts.firstWhere((alert) => alert.id == alertId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteAlert(String alertId) async {
    _sosAlerts.removeWhere((alert) => alert.id == alertId);
    await _saveAlerts();
    _notifyAlertsUpdate();
  }

  static void _simulateAlertPropagation(SosAlert alert) async {
    // Simulate alert propagation delay
    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(800)));
    
    // Simulate network acknowledgments from rescue teams
    final acknowledgers = ['rescue_team_1', 'medic_1', 'survivor_1'];
    
    for (int i = 0; i < acknowledgers.length; i++) {
      await Future.delayed(Duration(seconds: 2 + i * 3));
      
      if (Random().nextDouble() < 0.7) { // 70% chance of acknowledgment
        await acknowledgeSosAlert(alert.id, acknowledgers[i]);
      }
    }
  }

  static String _getDefaultSosMessage(SosPriority priority) {
    switch (priority) {
      case SosPriority.critical:
        return '🚨 CRITICAL EMERGENCY - Immediate assistance required!';
      case SosPriority.high:
        return '⚠️ URGENT - Need help as soon as possible';
      case SosPriority.medium:
        return '📢 ASSISTANCE NEEDED - Non-critical support required';
    }
  }

  static Future<void> _loadStoredAlerts() async {
    try {
      final alertsData = await StorageService.loadData(StorageService.sosAlertsKey);
      _sosAlerts = alertsData.map((json) => SosAlert.fromJson(json)).toList();
    } catch (e) {
      print('Error loading stored SOS alerts: $e');
      _sosAlerts = [];
    }
  }

  static Future<void> _saveAlerts() async {
    try {
      final alertsData = _sosAlerts.map((alert) => alert.toJson()).toList();
      await StorageService.saveData(StorageService.sosAlertsKey, alertsData);
    } catch (e) {
      print('Error saving SOS alerts: $e');
    }
  }

  static void _notifyAlertsUpdate() {
    _alertsController.add(List.from(_sosAlerts));
  }

  static int get totalAlerts => _sosAlerts.length;
  static int get activeAlertsCount => activeAlerts.length;
  static int get criticalAlertsCount => _sosAlerts.where((a) => a.priority == SosPriority.critical && a.status == SosStatus.active).length;

  static String get alertsSummary {
    final active = activeAlertsCount;
    final critical = criticalAlertsCount;
    
    if (critical > 0) return '$critical CRITICAL ALERTS';
    if (active > 0) return '$active Active Alerts';
    return 'No Active Alerts';
  }

  static void dispose() {
    _alertsController.close();
  }
}