import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/widgets/node_card.dart';
import 'package:beaconmesh/services/mesh_network_service.dart';
import 'package:beaconmesh/models/mesh_node.dart';

class NetworkMapScreen extends StatefulWidget {
  const NetworkMapScreen({super.key});

  @override
  State<NetworkMapScreen> createState() => _NetworkMapScreenState();
}

class _NetworkMapScreenState extends State<NetworkMapScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResQColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Network Map',
          style: TextStyle(color: ResQColors.darkOnSurface),
        ),
        backgroundColor: ResQColors.darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: ResQColors.darkOnSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ResQColors.darkOnSurface),
            onPressed: () => _refreshNetwork(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: ResQColors.darkOnSurface),
            color: ResQColors.darkSurface,
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Nodes'),
              ),
              const PopupMenuItem(
                value: 'connected',
                child: Text('Connected Only'),
              ),
              const PopupMenuItem(
                value: 'disconnected',
                child: Text('Disconnected Only'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Network summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: ResQColors.darkSurface,
            child: StreamBuilder(
              stream: MeshNetworkService.nodesStream,
              builder: (context, snapshot) {
                final totalNodes = MeshNetworkService.totalNodes;
                final activeNodes = MeshNetworkService.activeNodes;
                final networkStatus = MeshNetworkService.networkStatus;
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NetworkStatItem(
                          icon: Icons.hub,
                          label: 'Total Nodes',
                          value: totalNodes.toString(),
                          color: ResQColors.darkOnSurface,
                        ),
                        _NetworkStatItem(
                          icon: Icons.wifi,
                          label: 'Connected',
                          value: activeNodes.toString(),
                          color: ResQColors.safetyGreen,
                        ),
                        _NetworkStatItem(
                          icon: Icons.signal_wifi_off,
                          label: 'Offline',
                          value: (totalNodes - activeNodes).toString(),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: ResQColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        networkStatus,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ResQColors.darkOnSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Nodes list
          Expanded(
            child: StreamBuilder<List<MeshNode>>(
              stream: MeshNetworkService.nodesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allNodes = MeshNetworkService.meshNodes;
                final filteredNodes = _filterNodes(allNodes);

                if (filteredNodes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hub_outlined,
                          size: 64,
                          color: ResQColors.darkOnSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyMessage(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ResQColors.darkOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nodes will appear here as they join the mesh network',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ResQColors.darkOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshNetwork,
                          child: const Text('Refresh Network'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshNetwork,
                  color: ResQColors.emergencyOrange,
                  backgroundColor: ResQColors.darkSurface,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredNodes.length,
                    itemBuilder: (context, index) {
                      final node = filteredNodes[index];
                      return NodeCard(
                        node: node,
                        onTap: () => _showNodeDetails(node),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MeshNode> _filterNodes(List<MeshNode> nodes) {
    switch (_filterStatus) {
      case 'connected':
        return nodes.where((node) => node.status == NodeStatus.connected).toList();
      case 'disconnected':
        return nodes.where((node) => node.status == NodeStatus.disconnected).toList();
      default:
        return nodes;
    }
  }

  String _getEmptyMessage() {
    switch (_filterStatus) {
      case 'connected':
        return 'No connected nodes';
      case 'disconnected':
        return 'No disconnected nodes';
      default:
        return 'No nodes discovered';
    }
  }

  Future<void> _refreshNetwork() async {
    // Force network discovery refresh
    await MeshNetworkService.startNetworkDiscovery();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Network refreshed'),
          backgroundColor: ResQColors.darkSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNodeDetails(MeshNode node) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ResQColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _NodeDetailsSheet(node: node),
    );
  }
}

class _NetworkStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _NetworkStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ResQColors.darkOnSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NodeDetailsSheet extends StatelessWidget {
  final MeshNode node;

  const _NodeDetailsSheet({required this.node});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ResQColors.darkOnSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Node header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ResQColors.darkSurfaceVariant,
                child: Text(
                  node.user.name.isNotEmpty 
                      ? node.user.name.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: ResQColors.darkOnSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.user.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ResQColors.darkOnSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      node.displayStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(node.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Node details
          _DetailRow(
            icon: Icons.device_hub,
            label: 'Node ID',
            value: node.nodeId,
          ),
          _DetailRow(
            icon: Icons.phone_android,
            label: 'Device ID',
            value: node.user.deviceId,
          ),
          _DetailRow(
            icon: Icons.signal_cellular_alt,
            label: 'Signal Strength',
            value: '${(node.signalStrength * 100).toInt()}%',
          ),
          _DetailRow(
            icon: Icons.hub,
            label: 'Hop Count',
            value: node.hopCount.toString(),
          ),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Last Seen',
            value: _formatLastSeen(node.lastSeen),
          ),
          if (node.connectedNodes.isNotEmpty)
            _DetailRow(
              icon: Icons.group,
              label: 'Connected Nodes',
              value: node.connectedNodes.length.toString(),
            ),
          
          const SizedBox(height: 24),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Could navigate to message this specific node
              },
              child: const Text('Send Message'),
            ),
          ),
          const SizedBox(height: 20),
        ],
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

  String _formatLastSeen(DateTime lastSeen) {
    final duration = DateTime.now().difference(lastSeen);
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: ResQColors.emergencyOrange,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ResQColors.darkOnSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ResQColors.darkOnSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}