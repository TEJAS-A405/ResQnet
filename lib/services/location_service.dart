import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:beaconmesh/models/location_data.dart';

class LocationService {
  static LocationData? _lastKnownLocation;
  static bool _isLocationEnabled = false;

  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  static Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      if (!await isLocationServiceEnabled()) {
        print('Location services are disabled');
        return _lastKnownLocation;
      }

      // Check permissions
      if (!await checkLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          print('Location permission not granted');
          return _lastKnownLocation;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      _isLocationEnabled = true;
      return _lastKnownLocation;
    } catch (e) {
      print('Error getting current location: $e');
      _isLocationEnabled = false;
      return _lastKnownLocation;
    }
  }

  static Future<void> updateLocationInBackground() async {
    try {
      if (await checkLocationPermission() && await isLocationServiceEnabled()) {
        await getCurrentLocation();
      }
    } catch (e) {
      print('Error updating location in background: $e');
    }
  }

  static LocationData? get lastKnownLocation => _lastKnownLocation;
  
  static bool get isLocationEnabled => _isLocationEnabled;

  static String get locationStatus {
    if (!_isLocationEnabled) return 'Location Disabled';
    if (_lastKnownLocation == null) return 'Getting Location...';
    final age = DateTime.now().difference(_lastKnownLocation!.timestamp);
    if (age.inMinutes < 5) return 'Location Active';
    return 'Location Stale (${age.inMinutes}m ago)';
  }

  static Future<void> startLocationUpdates() async {
    // Update location every 30 seconds when active
    await updateLocationInBackground();
  }

  static void stopLocationUpdates() {
    _isLocationEnabled = false;
  }
}