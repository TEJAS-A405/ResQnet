import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/models/mesh_node.dart';

class NodeCard extends StatelessWidget {
  final MeshNode node;
  final VoidCallback? onTap;
  
  const NodeCard({
    super.key,
    required this.node,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(node.status);
    final timeSinceLastSeen = DateTime.now().difference(node.lastSeen);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: ResQColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Node status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: node.isOnline ? [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: ResQColors.darkSurfaceVariant,
                child: Text(
                  node.user.name.isNotEmpty 
                      ? node.user.name.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: ResQColors.darkOnSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Node information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ResQColors.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          node.displayStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (node.hopCount > 0) ...[
                          Text(
                            ' • ${node.hopCount} hops',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ResQColors.darkOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last seen: ${_formatLastSeen(timeSinceLastSeen)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ResQColors.darkOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Signal strength indicator
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSignalStrengthIndicator(node.signalStrength),
                  const SizedBox(height: 4),
                  Text(
                    '${(node.signalStrength * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ResQColors.darkOnSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              // Connected nodes count
              if (node.connectedNodes.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ResQColors.emergencyOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${node.connectedNodes.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ResQColors.emergencyOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.connected:
        return ResQColors.safetyGreen;
      case NodeStatus.weak:
        return ResQColors.warningYellow;
      case NodeStatus.disconnected:
        return Colors.grey;
    }
  }

  Widget _buildSignalStrengthIndicator(double strength) {
    final bars = (strength * 4).round().clamp(0, 4);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < bars;
        final height = 4.0 + (index * 2);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 2,
          height: height,
          decoration: BoxDecoration(
            color: isActive 
                ? _getSignalColor(strength)
                : ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Color _getSignalColor(double strength) {
    if (strength >= 0.7) return ResQColors.safetyGreen;
    if (strength >= 0.4) return ResQColors.warningYellow;
    return ResQColors.emergencyRed;
  }

  String _formatLastSeen(Duration duration) {
    if (duration.inSeconds < 30) {
      return 'Just now';
    } else if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }
}