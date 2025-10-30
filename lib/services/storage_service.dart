import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _messagesKey = 'mesh_messages';
  static const String _nodesKey = 'mesh_nodes';
  static const String _sosAlertsKey = 'sos_alerts';
  static const String _userKey = 'current_user';
  static const String _settingsKey = 'app_settings';

  static Future<void> saveData(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving data for key $key: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> loadData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final decoded = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      print('Error loading data for key $key: $e');
      return [];
    }
  }

  static Future<void> saveObject(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving object for key $key: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadObject(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) return null;
      
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      print('Error loading object for key $key: $e');
      return null;
    }
  }

  static Future<void> clearData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Error clearing data for key $key: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Specific storage keys for easy access
  static String get messagesKey => _messagesKey;
  static String get nodesKey => _nodesKey;
  static String get sosAlertsKey => _sosAlertsKey;
  static String get userKey => _userKey;
  static String get settingsKey => _settingsKey;
}