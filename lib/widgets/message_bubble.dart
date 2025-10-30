import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/models/message.dart';
import 'package:beaconmesh/services/user_service.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showSenderName;
  
  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.currentUser;
    final isOwnMessage = currentUser?.id == message.sender.id;
    final isSosMessage = message.type == MessageType.sos;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: ResQColors.darkSurfaceVariant,
              child: Text(
                message.sender.name.isNotEmpty 
                    ? message.sender.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: ResQColors.darkOnSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSosMessage 
                    ? ResQColors.emergencyRed.withValues(alpha: 0.9)
                    : (isOwnMessage 
                        ? ResQColors.emergencyOrange.withValues(alpha: 0.8)
                        : ResQColors.darkSurfaceVariant),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
                  bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
                ),
                border: isSosMessage 
                    ? Border.all(color: ResQColors.emergencyRed, width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSenderName && !isOwnMessage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.sender.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ResQColors.emergencyOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSosMessage || isOwnMessage 
                          ? Colors.white 
                          : ResQColors.darkOnSurface,
                      fontWeight: isSosMessage ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (message.location != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isSosMessage || isOwnMessage 
                                ? Colors.white70 
                                : ResQColors.darkOnSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            message.location!.formattedLocation,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSosMessage || isOwnMessage 
                                  ? Colors.white70 
                                  : ResQColors.darkOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(message.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSosMessage || isOwnMessage 
                              ? Colors.white70 
                              : ResQColors.darkOnSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      if (isOwnMessage) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(),
                      ],
                      if (message.hopCount > 0) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.hub,
                          size: 10,
                          color: isSosMessage || isOwnMessage 
                              ? Colors.white70 
                              : ResQColors.darkOnSurfaceVariant,
                        ),
                        Text(
                          '${message.hopCount}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSosMessage || isOwnMessage 
                                ? Colors.white70 
                                : ResQColors.darkOnSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isOwnMessage) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = Colors.white70;
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        color = Colors.white70;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = ResQColors.emergencyRed;
        break;
    }
    
    return Icon(
      icon,
      size: 12,
      color: color,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}