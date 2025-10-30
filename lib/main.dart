import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/screens/home_screen.dart';
import 'package:beaconmesh/services/user_service.dart';
import 'package:beaconmesh/services/mesh_network_service.dart';
import 'package:beaconmesh/services/message_service.dart';
import 'package:beaconmesh/services/sos_service.dart';
import 'package:beaconmesh/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services
  await UserService.getCurrentUser();
  await MeshNetworkService.initializeNetwork();
  await MessageService.initializeMessages();
  await SosService.initializeSosService();
  LocationService.startLocationUpdates();
  
  runApp(const ResQnetApp());
}

class ResQnetApp extends StatelessWidget {
  const ResQnetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQnet - Emergency Mesh Network',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode for battery optimization
      home: const HomeScreen(),
    );
  }
}
