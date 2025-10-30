import 'dart:async';
import 'dart:math';
import 'package:beaconmesh/models/mesh_node.dart';
import 'package:beaconmesh/models/user.dart';
import 'package:beaconmesh/services/storage_service.dart';
import 'package:beaconmesh/services/user_service.dart';

class MeshNetworkService {
  static List<MeshNode> _meshNodes = [];
  static bool _isNetworkActive = false;
  static Timer? _discoveryTimer;
  static final StreamController<List<MeshNode>> _nodesController = StreamController<List<MeshNode>>.broadcast();

  static Stream<List<MeshNode>> get nodesStream => _nodesController.stream;
  static List<MeshNode> get meshNodes => List.from(_meshNodes);
  static List<MeshNode> get connectedNodes => _meshNodes.where((node) => node.isOnline).toList();
  static int get totalNodes => _meshNodes.length;
  static int get activeNodes => connectedNodes.length;
  static bool get isNetworkActive => _isNetworkActive;

  static Future<void> initializeNetwork() async {
    await _loadStoredNodes();
    await startNetworkDiscovery();
    
    // Initialize with some mock peer nodes for demonstration
    if (_meshNodes.isEmpty) {
      await _createMockPeerNodes();
    }
  }

  static Future<void> startNetworkDiscovery() async {
    _isNetworkActive = true;
    
    // Start periodic network discovery (simulated)
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _simulateNetworkDiscovery();
    });

    _notifyNodesUpdate();
  }

  static Future<void> stopNetworkDiscovery() async {
    _isNetworkActive = false;
    _discoveryTimer?.cancel();
    
    // Mark all nodes as disconnected
    for (int i = 0; i < _meshNodes.length; i++) {
      _meshNodes[i] = _meshNodes[i].copyWith(
        status: NodeStatus.disconnected,
        updatedAt: DateTime.now(),
      );
    }
    
    await _saveNodes();
    _notifyNodesUpdate();
  }

  static Future<void> addPeerNode(User user) async {
    final existingIndex = _meshNodes.indexWhere((node) => node.nodeId == user.id);
    final now = DateTime.now();

    if (existingIndex >= 0) {
      // Update existing node
      _meshNodes[existingIndex] = _meshNodes[existingIndex].copyWith(
        user: user,
        status: NodeStatus.connected,
        lastSeen: now,
        updatedAt: now,
      );
    } else {
      // Add new node
      final newNode = MeshNode(
        nodeId: user.id,
        user: user,
        status: NodeStatus.connected,
        hopCount: 1,
        signalStrength: 0.8 + Random().nextDouble() * 0.2, // Random signal 0.8-1.0
        lastSeen: now,
        connectedNodes: [],
        createdAt: now,
        updatedAt: now,
      );
      _meshNodes.add(newNode);
    }

    await _saveNodes();
    _notifyNodesUpdate();
  }

  static Future<void> removePeerNode(String nodeId) async {
    _meshNodes.removeWhere((node) => node.nodeId == nodeId);
    await _saveNodes();
    _notifyNodesUpdate();
  }

  static MeshNode? getNodeById(String nodeId) {
    try {
      return _meshNodes.firstWhere((node) => node.nodeId == nodeId);
    } catch (e) {
      return null;
    }
  }

  static int getHopCount(String nodeId) {
    final node = getNodeById(nodeId);
    return node?.hopCount ?? -1;
  }

  static List<String> getRoutePath(String destinationNodeId) {
    final node = getNodeById(destinationNodeId);
    if (node == null) return [];
    
    // Simplified route path simulation
    final currentUser = UserService.currentUser;
    if (currentUser == null) return [];
    
    return [currentUser.id, destinationNodeId];
  }

  static Future<void> _simulateNetworkDiscovery() async {
    final random = Random();
    
    // Simulate node status changes
    for (int i = 0; i < _meshNodes.length; i++) {
      final node = _meshNodes[i];
      final shouldUpdate = random.nextDouble() < 0.3; // 30% chance of status change
      
      if (shouldUpdate) {
        NodeStatus newStatus;
        if (node.status == NodeStatus.connected) {
          newStatus = random.nextBool() ? NodeStatus.weak : NodeStatus.disconnected;
        } else {
          newStatus = random.nextBool() ? NodeStatus.connected : NodeStatus.weak;
        }
        
        _meshNodes[i] = node.copyWith(
          status: newStatus,
          signalStrength: 0.5 + random.nextDouble() * 0.5,
          lastSeen: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }
    
    await _saveNodes();
    _notifyNodesUpdate();
  }

  static Future<void> _createMockPeerNodes() async {
    final mockUsers = [
      User(
        id: 'rescue_team_1',
        name: 'Rescue Team Alpha',
        deviceId: 'rescue_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isOnline: true,
      ),
      User(
        id: 'survivor_1',
        name: 'Emergency Contact',
        deviceId: 'survivor_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isOnline: true,
      ),
      User(
        id: 'medic_1',
        name: 'Field Medic',
        deviceId: 'medic_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isOnline: true,
      ),
    ];

    for (final user in mockUsers) {
      await addPeerNode(user);
    }
  }

  static Future<void> _loadStoredNodes() async {
    try {
      final nodesData = await StorageService.loadData(StorageService.nodesKey);
      _meshNodes = nodesData.map((json) => MeshNode.fromJson(json)).toList();
    } catch (e) {
      print('Error loading stored nodes: $e');
      _meshNodes = [];
    }
  }

  static Future<void> _saveNodes() async {
    try {
      final nodesData = _meshNodes.map((node) => node.toJson()).toList();
      await StorageService.saveData(StorageService.nodesKey, nodesData);
    } catch (e) {
      print('Error saving nodes: $e');
    }
  }

  static void _notifyNodesUpdate() {
    _nodesController.add(List.from(_meshNodes));
  }

  static String get networkStatus {
    if (!_isNetworkActive) return 'Network Inactive';
    final active = activeNodes;
    final total = totalNodes;
    if (active == 0) return 'No Connections';
    return '$active/$total nodes connected';
  }

  static void dispose() {
    _discoveryTimer?.cancel();
    _nodesController.close();
  }
}