import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/widgets/message_bubble.dart';
import 'package:beaconmesh/services/message_service.dart';
import 'package:beaconmesh/services/location_service.dart';
import 'package:beaconmesh/models/message.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _includeLocation = false;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await MessageService.sendMessage(
        content,
        includeLocation: _includeLocation,
      );
      
      _messageController.clear();
      
      // Scroll to bottom to show new message
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: ResQColors.emergencyRed,
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResQColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Mesh Messages',
          style: TextStyle(color: ResQColors.darkOnSurface),
        ),
        backgroundColor: ResQColors.darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: ResQColors.darkOnSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: ResQColors.darkOnSurface),
            onPressed: () => _showMessageInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: MessageService.messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = MessageService.getRecentMessages();
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: ResQColors.darkOnSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ResQColors.darkOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with your mesh network',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ResQColors.darkOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollToBottom();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),

          // Message input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ResQColors.darkSurface,
              border: Border(
                top: BorderSide(
                  color: ResQColors.darkOnSurfaceVariant.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location toggle
                  Row(
                    children: [
                      Icon(
                        _includeLocation ? Icons.location_on : Icons.location_off,
                        size: 16,
                        color: _includeLocation 
                            ? ResQColors.safetyGreen 
                            : ResQColors.darkOnSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LocationService.locationStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ResQColors.darkOnSurfaceVariant,
                          ),
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
                  const SizedBox(height: 12),
                  
                  // Message input
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: ResQColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(color: ResQColors.darkOnSurface),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(
                                color: ResQColors.darkOnSurfaceVariant,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: ResQColors.emergencyOrange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSending 
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send),
                          color: Colors.white,
                          onPressed: _isSending ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ResQColors.darkSurface,
          title: Text(
            'Mesh Messaging',
            style: TextStyle(color: ResQColors.darkOnSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.hub,
                title: 'Multi-hop routing',
                description: 'Messages route through connected mesh nodes',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.location_on,
                title: 'Location sharing',
                description: 'Optionally include GPS coordinates',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.offline_bolt,
                title: 'Offline capable',
                description: 'Works without internet or cellular',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(color: ResQColors.emergencyOrange),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: ResQColors.emergencyOrange,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: ResQColors.darkOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ResQColors.darkOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}