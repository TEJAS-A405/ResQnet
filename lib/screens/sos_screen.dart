import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/widgets/sos_button.dart';
import 'package:beaconmesh/services/sos_service.dart';
import 'package:beaconmesh/services/location_service.dart';
import 'package:beaconmesh/models/sos_alert.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final TextEditingController _customMessageController = TextEditingController();
  SosPriority _selectedPriority = SosPriority.critical;
  bool _includeLocation = true;

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResQColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Emergency SOS',
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
            // Emergency warning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ResQColors.emergencyRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ResQColors.emergencyRed.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: ResQColors.emergencyRed,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ EMERGENCY USE ONLY',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ResQColors.emergencyRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SOS alerts are broadcast to all mesh network participants. Only use in genuine emergency situations.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ResQColors.darkOnSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick SOS Button
            Center(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: SosService.alertsStream,
                    builder: (context, snapshot) {
                      final hasActiveAlerts = SosService.activeAlertsCount > 0;
                      return SosButton(
                        size: 160,
                        isActive: hasActiveAlerts,
                        onPressed: () {
                          // Additional feedback if needed
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick Emergency Alert',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ResQColors.darkOnSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to send immediate critical emergency alert',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ResQColors.darkOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Custom SOS Configuration
            Text(
              'Custom Emergency Alert',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Priority selection
            Text(
              'Priority Level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriorityButton(
                    priority: SosPriority.critical,
                    isSelected: _selectedPriority == SosPriority.critical,
                    onTap: () => setState(() => _selectedPriority = SosPriority.critical),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriorityButton(
                    priority: SosPriority.high,
                    isSelected: _selectedPriority == SosPriority.high,
                    onTap: () => setState(() => _selectedPriority = SosPriority.high),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriorityButton(
                    priority: SosPriority.medium,
                    isSelected: _selectedPriority == SosPriority.medium,
                    onTap: () => setState(() => _selectedPriority = SosPriority.medium),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Custom message input
            Text(
              'Custom Message (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ResQColors.darkOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: ResQColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _customMessageController,
                style: TextStyle(color: ResQColors.darkOnSurface),
                decoration: InputDecoration(
                  hintText: 'Describe your emergency situation...',
                  hintStyle: TextStyle(
                    color: ResQColors.darkOnSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 24),

            // Location toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ResQColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _includeLocation 
                        ? ResQColors.safetyGreen 
                        : ResQColors.darkOnSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Include Location',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ResQColors.darkOnSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          LocationService.locationStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ResQColors.darkOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _includeLocation,
                    onChanged: (value) => setState(() => _includeLocation = value),
                    activeColor: ResQColors.safetyGreen,
                    inactiveTrackColor: ResQColors.darkSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Send custom SOS button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _sendCustomSos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPriorityColor(_selectedPriority),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sos, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Send ${_selectedPriority.name.toUpperCase()} Alert',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Active alerts section
            StreamBuilder(
              stream: SosService.alertsStream,
              builder: (context, snapshot) {
                final activeAlerts = SosService.activeAlerts;
                if (activeAlerts.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Alerts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ResQColors.darkOnSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...activeAlerts.map((alert) => _AlertCard(alert: alert)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCustomSos() async {
    try {
      await SosService.broadcastSosAlert(
        customMessage: _customMessageController.text.trim().isNotEmpty 
            ? _customMessageController.text.trim() 
            : null,
        priority: _selectedPriority,
        includeLocation: _includeLocation,
      );

      _customMessageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: ResQColors.safetyGreen),
                const SizedBox(width: 8),
                Text('${_selectedPriority.name.toUpperCase()} alert sent successfully'),
              ],
            ),
            backgroundColor: ResQColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: ResQColors.emergencyRed),
                const SizedBox(width: 8),
                const Text('Failed to send SOS alert'),
              ],
            ),
            backgroundColor: ResQColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getPriorityColor(SosPriority priority) {
    switch (priority) {
      case SosPriority.critical:
        return ResQColors.emergencyRed;
      case SosPriority.high:
        return ResQColors.emergencyOrange;
      case SosPriority.medium:
        return ResQColors.warningYellow;
    }
  }
}

class _PriorityButton extends StatelessWidget {
  final SosPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityButton({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.2)
              : ResQColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getPriorityIcon(priority),
              color: isSelected ? color : ResQColors.darkOnSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              priority.name.toUpperCase(),
              style: TextStyle(
                color: isSelected ? color : ResQColors.darkOnSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(SosPriority priority) {
    switch (priority) {
      case SosPriority.critical:
        return ResQColors.emergencyRed;
      case SosPriority.high:
        return ResQColors.emergencyOrange;
      case SosPriority.medium:
        return ResQColors.warningYellow;
    }
  }

  IconData _getPriorityIcon(SosPriority priority) {
    switch (priority) {
      case SosPriority.critical:
        return Icons.local_fire_department;
      case SosPriority.high:
        return Icons.warning;
      case SosPriority.medium:
        return Icons.info;
    }
  }
}

class _AlertCard extends StatelessWidget {
  final SosAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(alert.priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResQColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sos,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                alert.displayPriority,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(alert.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ResQColors.darkOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ResQColors.darkOnSurface,
            ),
          ),
          if (alert.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: ResQColors.darkOnSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  alert.location!.formattedLocation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ResQColors.darkOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (alert.acknowledgedBy.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '✓ Acknowledged by ${alert.acknowledgedBy.length} responders',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ResQColors.safetyGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(SosPriority priority) {
    switch (priority) {
      case SosPriority.critical:
        return ResQColors.emergencyRed;
      case SosPriority.high:
        return ResQColors.emergencyOrange;
      case SosPriority.medium:
        return ResQColors.warningYellow;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}