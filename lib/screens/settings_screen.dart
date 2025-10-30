import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/services/user_service.dart';
import 'package:beaconmesh/services/mesh_network_service.dart';
import 'package:beaconmesh/services/location_service.dart';
import 'package:beaconmesh/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _networkEnabled = true;
  bool _locationEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() async {
    final currentUser = await UserService.getCurrentUser();
    _nameController.text = currentUser.name;
    
    setState(() {
      _networkEnabled = MeshNetworkService.isNetworkActive;
      _locationEnabled = LocationService.isLocationEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResQColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: ResQColors.darkOnSurface),
        ),
        backgroundColor: ResQColors.darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: ResQColors.darkOnSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ResQColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile avatar and device info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: ResQColors.emergencyOrange.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: ResQColors.emergencyOrange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserService.displayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: ResQColors.darkOnSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Device: ${UserService.deviceId}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ResQColors.darkOnSurfaceVariant,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: UserService.isOnline 
                                    ? ResQColors.safetyGreen.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                UserService.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color: UserService.isOnline 
                                      ? ResQColors.safetyGreen 
                                      : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Name input
                  Text(
                    'Display Name',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ResQColors.darkOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ResQColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: ResQColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'Enter your name...',
                        hintStyle: TextStyle(
                          color: ResQColors.darkOnSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onSubmitted: (_) => _updateUserName(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateUserName,
                      child: _isLoading 
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Name'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Network Settings
            Text(
              'Network Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _SettingsCard(
              icon: Icons.wifi,
              title: 'Mesh Network',
              subtitle: _networkEnabled 
                  ? 'Actively discovering and connecting to peers'
                  : 'Network discovery disabled',
              trailing: Switch(
                value: _networkEnabled,
                onChanged: _toggleNetwork,
                activeColor: ResQColors.safetyGreen,
                inactiveTrackColor: ResQColors.darkSurfaceVariant,
              ),
            ),
            
            _SettingsCard(
              icon: Icons.location_on,
              title: 'Location Services',
              subtitle: LocationService.locationStatus,
              trailing: Switch(
                value: _locationEnabled,
                onChanged: _toggleLocation,
                activeColor: ResQColors.safetyGreen,
                inactiveTrackColor: ResQColors.darkSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // App Settings
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _SettingsCard(
              icon: Icons.info_outline,
              title: 'About ResQnet',
              subtitle: 'Emergency Mesh Network v1.0.0',
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: ResQColors.darkOnSurfaceVariant,
                size: 16,
              ),
              onTap: _showAboutDialog,
            ),
            
            _SettingsCard(
              icon: Icons.help_outline,
              title: 'Emergency Help',
              subtitle: 'How to use ResQnet in emergency situations',
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: ResQColors.darkOnSurfaceVariant,
                size: 16,
              ),
              onTap: _showHelpDialog,
            ),
            const SizedBox(height: 32),

            // Data Management
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _SettingsCard(
              icon: Icons.delete_sweep,
              title: 'Clear All Data',
              subtitle: 'Remove all messages, alerts, and network data',
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: ResQColors.emergencyRed,
                size: 16,
              ),
              onTap: _confirmClearData,
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      await UserService.updateUserProfile(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: ResQColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: ResQColors.emergencyRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleNetwork(bool enabled) async {
    setState(() => _networkEnabled = enabled);
    
    try {
      if (enabled) {
        await MeshNetworkService.startNetworkDiscovery();
      } else {
        await MeshNetworkService.stopNetworkDiscovery();
      }
    } catch (e) {
      setState(() => _networkEnabled = !enabled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${enabled ? 'enable' : 'disable'} network'),
            backgroundColor: ResQColors.emergencyRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleLocation(bool enabled) async {
    setState(() => _locationEnabled = enabled);
    
    try {
      if (enabled) {
        await LocationService.startLocationUpdates();
      } else {
        LocationService.stopLocationUpdates();
      }
    } catch (e) {
      setState(() => _locationEnabled = !enabled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${enabled ? 'enable' : 'disable'} location'),
            backgroundColor: ResQColors.emergencyRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ResQColors.darkSurface,
        title: Text(
          'About ResQnet',
          style: TextStyle(color: ResQColors.darkOnSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ResQnet is a decentralized emergency communication platform designed for disaster scenarios.',
              style: TextStyle(color: ResQColors.darkOnSurface),
            ),
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '• Peer-to-peer mesh networking\n• Emergency SOS broadcasting\n• GPS location sharing\n• Offline-first operation\n• Battery-optimized interface',
              style: TextStyle(color: ResQColors.darkOnSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: ResQColors.emergencyOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ResQColors.darkSurface,
        title: Text(
          'Emergency Help',
          style: TextStyle(color: ResQColors.darkOnSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use ResQnet in emergencies:',
              style: TextStyle(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '1. Keep your device close to other ResQnet users\n2. Enable location services for accurate GPS\n3. Use the red SOS button for critical emergencies\n4. Send messages to coordinate rescue efforts\n5. Monitor the network map for nearby responders',
              style: TextStyle(color: ResQColors.darkOnSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Understood',
              style: TextStyle(color: ResQColors.emergencyOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ResQColors.darkSurface,
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: ResQColors.emergencyRed,
            ),
            const SizedBox(width: 12),
            Text(
              'Clear All Data?',
              style: TextStyle(color: ResQColors.darkOnSurface),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all messages, SOS alerts, and network data. This action cannot be undone.',
          style: TextStyle(color: ResQColors.darkOnSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ResQColors.darkOnSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ResQColors.emergencyRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      await StorageService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All data cleared successfully'),
            backgroundColor: ResQColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: ResQColors.emergencyRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ResQColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: isDestructive 
            ? Border.all(color: ResQColors.emergencyRed.withValues(alpha: 0.3))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive 
                    ? ResQColors.emergencyRed 
                    : ResQColors.emergencyOrange,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDestructive 
                            ? ResQColors.emergencyRed 
                            : ResQColors.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ResQColors.darkOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}