import 'dart:async';
import 'dart:math';
import 'package:beaconmesh/models/message.dart';
import 'package:beaconmesh/models/user.dart';
import 'package:beaconmesh/services/storage_service.dart';
import 'package:beaconmesh/services/mesh_network_service.dart';
import 'package:beaconmesh/services/user_service.dart';
import 'package:beaconmesh/services/location_service.dart';

class MessageService {
  static List<Message> _messages = [];
  static final StreamController<List<Message>> _messagesController = StreamController<List<Message>>.broadcast();

  static Stream<List<Message>> get messagesStream => _messagesController.stream;
  static List<Message> get allMessages => List.from(_messages);

  static Future<void> initializeMessages() async {
    await _loadStoredMessages();
    _notifyMessagesUpdate();
  }

  static Future<Message> sendMessage(
    String content, {
    String? recipientId,
    bool includeLocation = false,
  }) async {
    final currentUser = await UserService.getCurrentUser();
    final now = DateTime.now();
    
    // Generate unique message ID
    final messageId = 'msg_${now.millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    
    // Get location if requested
    final location = includeLocation ? LocationService.lastKnownLocation : null;
    
    // Create message
    final message = Message(
      id: messageId,
      content: content,
      sender: currentUser,
      recipientId: recipientId,
      type: MessageType.text,
      status: MessageStatus.sending,
      location: location,
      createdAt: now,
      updatedAt: now,
      hopCount: 0,
      routePath: [currentUser.id],
    );

    // Add to local messages
    _messages.add(message);
    await _saveMessages();
    _notifyMessagesUpdate();

    // Simulate mesh routing
    _simulateMessageRouting(message);

    return message;
  }

  static Future<void> receiveMessage(Message message) async {
    // Check if message already exists
    final existingIndex = _messages.indexWhere((m) => m.id == message.id);
    if (existingIndex >= 0) return;

    // Add received message
    _messages.add(message.copyWith(
      status: MessageStatus.delivered,
      updatedAt: DateTime.now(),
    ));

    await _saveMessages();
    _notifyMessagesUpdate();
  }

  static List<Message> getMessagesForRecipient(String recipientId) {
    return _messages.where((message) => 
      message.recipientId == recipientId || 
      message.sender.id == recipientId
    ).toList();
  }

  static List<Message> getBroadcastMessages() {
    return _messages.where((message) => message.recipientId == null).toList();
  }

  static List<Message> getRecentMessages({int limit = 50}) {
    final sortedMessages = List<Message>.from(_messages);
    sortedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedMessages.take(limit).toList();
  }

  static Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex >= 0) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      
      await _saveMessages();
      _notifyMessagesUpdate();
    }
  }

  static Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((message) => message.id == messageId);
    await _saveMessages();
    _notifyMessagesUpdate();
  }

  static void _simulateMessageRouting(Message message) async {
    // Simulate network routing delay
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1500)));
    
    // Get route path
    final routePath = message.recipientId != null 
        ? MeshNetworkService.getRoutePath(message.recipientId!)
        : [message.sender.id]; // Broadcast message
    
    final hopCount = routePath.length - 1;
    
    // Update message with routing information
    final routedMessage = message.copyWith(
      status: hopCount <= 3 ? MessageStatus.sent : MessageStatus.delivered,
      hopCount: hopCount,
      routePath: routePath,
      updatedAt: DateTime.now(),
    );

    // Update in local storage
    final messageIndex = _messages.indexWhere((m) => m.id == message.id);
    if (messageIndex >= 0) {
      _messages[messageIndex] = routedMessage;
      await _saveMessages();
      _notifyMessagesUpdate();
    }

    // Simulate final delivery confirmation
    if (hopCount <= 5) { // Successful routing
      await Future.delayed(Duration(seconds: 2 + Random().nextInt(3)));
      await updateMessageStatus(message.id, MessageStatus.delivered);
    } else {
      // Message failed - too many hops
      await Future.delayed(const Duration(seconds: 5));
      await updateMessageStatus(message.id, MessageStatus.failed);
    }
  }

  static Future<void> _loadStoredMessages() async {
    try {
      final messagesData = await StorageService.loadData(StorageService.messagesKey);
      _messages = messagesData.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error loading stored messages: $e');
      _messages = [];
    }
  }

  static Future<void> _saveMessages() async {
    try {
      final messagesData = _messages.map((message) => message.toJson()).toList();
      await StorageService.saveData(StorageService.messagesKey, messagesData);
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  static void _notifyMessagesUpdate() {
    _messagesController.add(List.from(_messages));
  }

  static int get totalMessages => _messages.length;
  static int get unreadMessages => _messages.where((m) => m.status == MessageStatus.sending).length;

  static void dispose() {
    _messagesController.close();
  }
}