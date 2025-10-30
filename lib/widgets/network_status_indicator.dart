import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/services/mesh_network_service.dart';
import 'package:beaconmesh/services/location_service.dart';

class NetworkStatusIndicator extends StatefulWidget {
  final bool showDetails;
  
  const NetworkStatusIndicator({
    super.key,
    this.showDetails = true,
  });

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MeshNetworkService.nodesStream,
      builder: (context, snapshot) {
        final activeNodes = MeshNetworkService.activeNodes;
        final totalNodes = MeshNetworkService.totalNodes;
        final isNetworkActive = MeshNetworkService.isNetworkActive;
        final locationStatus = LocationService.locationStatus;

        Color statusColor;
        IconData statusIcon;
        String statusText;

        if (!isNetworkActive) {
          statusColor = Colors.grey;
          statusIcon = Icons.portable_wifi_off;
          statusText = 'Network Offline';
        } else if (activeNodes == 0) {
          statusColor = ResQColors.emergencyRed;
          statusIcon = Icons.signal_wifi_off;
          statusText = 'No Connections';
        } else if (activeNodes <= 2) {
          statusColor = ResQColors.warningYellow;
          statusIcon = Icons.signal_wifi_4_bar;
          statusText = 'Weak Network';
        } else {
          statusColor = ResQColors.safetyGreen;
          statusIcon = Icons.wifi;
          statusText = 'Network Strong';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ResQColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.showDetails)
                          Text(
                            '$activeNodes/$totalNodes nodes connected',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ResQColors.darkOnSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildSignalStrengthIndicator(activeNodes),
                ],
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 12),
                Divider(color: ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: LocationService.isLocationEnabled 
                          ? ResQColors.safetyGreen 
                          : ResQColors.emergencyRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ResQColors.darkOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignalStrengthIndicator(int activeNodes) {
    final strength = activeNodes == 0 ? 0 : 
                    activeNodes <= 2 ? 1 : 
                    activeNodes <= 5 ? 2 : 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < strength;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 3,
          height: 8 + (index * 4),
          decoration: BoxDecoration(
            color: isActive 
                ? (strength == 1 ? ResQColors.warningYellow : ResQColors.safetyGreen)
                : ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}