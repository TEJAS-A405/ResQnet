import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/widgets/sos_button.dart';
import 'package:beaconmesh/widgets/network_status_indicator.dart';
import 'package:beaconmesh/screens/messages_screen.dart';
import 'package:beaconmesh/screens/network_map_screen.dart';
import 'package:beaconmesh/screens/sos_screen.dart';
import 'package:beaconmesh/screens/settings_screen.dart';
import 'package:beaconmesh/services/sos_service.dart';
import 'package:beaconmesh/services/mesh_network_service.dart';
import 'package:beaconmesh/services/message_service.dart';
import 'package:beaconmesh/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const _DashboardTab(),
    const MessagesScreen(),
    const NetworkMapScreen(),
    const SosScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResQColors.darkBackground,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ResQColors.darkSurface,
          border: Border(
            top: BorderSide(
              color: ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: ResQColors.emergencyOrange,
          unselectedItemColor: ResQColors.darkOnSurfaceVariant,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hub),
              label: 'Network',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sos),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ResQColors.emergencyOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: ResQColors.emergencyOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ResQnet',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: ResQColors.darkOnSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Emergency Mesh Network',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ResQColors.darkOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Network Status
            const NetworkStatusIndicator(),
            const SizedBox(height: 24),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _QuickStatCard(
                    icon: Icons.people,
                    title: 'Connected',
                    value: '${MeshNetworkService.activeNodes}',
                    color: ResQColors.safetyGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder(
                    stream: MessageService.messagesStream,
                    builder: (context, snapshot) {
                      return _QuickStatCard(
                        icon: Icons.message,
                        title: 'Messages',
                        value: '${MessageService.totalMessages}',
                        color: ResQColors.emergencyOrange,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder(
                    stream: SosService.alertsStream,
                    builder: (context, snapshot) {
                      final activeAlerts = SosService.activeAlertsCount;
                      return _QuickStatCard(
                        icon: Icons.warning,
                        title: 'Alerts',
                        value: '$activeAlerts',
                        color: activeAlerts > 0 ? ResQColors.emergencyRed : Colors.grey,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Emergency SOS Button
            Center(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: SosService.alertsStream,
                    builder: (context, snapshot) {
                      final hasActiveAlerts = SosService.activeAlertsCount > 0;
                      return SosButton(
                        size: 140,
                        isActive: hasActiveAlerts,
                        onPressed: () {
                          // Additional feedback or navigation if needed
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Emergency SOS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ResQColors.darkOnSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to broadcast emergency alert\nto all connected mesh nodes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ResQColors.darkOnSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.chat,
                    label: 'Send Message',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessagesScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.hub,
                    label: 'View Network',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NetworkMapScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResQColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ResQColors.darkOnSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ResQColors.darkOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ResQColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ResQColors.emergencyOrange.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: ResQColors.emergencyOrange,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}