import 'package:flutter/material.dart';
import 'package:beaconmesh/theme.dart';
import 'package:beaconmesh/services/sos_service.dart';
import 'package:beaconmesh/models/sos_alert.dart';

class SosButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double size;
  final bool isActive;

  const SosButton({
    super.key,
    this.onPressed,
    this.size = 120,
    this.isActive = false,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (_showConfirmation) return;
    
    setState(() {
      _isPressed = true;
      _showConfirmation = true;
    });

    // Show confirmation dialog
    final confirmed = await _showSosConfirmationDialog();
    
    if (confirmed == true) {
      await _sendSosAlert();
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    }
    
    setState(() {
      _isPressed = false;
      _showConfirmation = false;
    });
  }

  Future<bool?> _showSosConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ResQColors.darkSurface,
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: ResQColors.emergencyRed,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Send SOS Alert?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ResQColors.darkOnSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will broadcast a critical emergency alert to all nearby ResQnet users.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ResQColors.darkOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '⚠️ Only use in real emergencies',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ResQColors.warningYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: ResQColors.darkOnSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ResQColors.emergencyRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('SEND SOS'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSosAlert() async {
    try {
      await SosService.broadcastSosAlert(
        priority: SosPriority.critical,
        includeLocation: true,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: ResQColors.safetyGreen),
                const SizedBox(width: 8),
                const Text('SOS Alert sent to mesh network'),
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
                const Text('Failed to send SOS Alert'),
              ],
            ),
            backgroundColor: ResQColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _pulseAnimation.value : (_isPressed ? _scaleAnimation.value : 1.0),
          child: GestureDetector(
            onTap: _showConfirmation ? null : _handleTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _showConfirmation 
                      ? [ResQColors.warningYellow, ResQColors.emergencyOrange]
                      : [ResQColors.emergencyRed, const Color(0xFFCC0000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ResQColors.emergencyRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showConfirmation ? Icons.hourglass_empty : Icons.sos,
                    color: Colors.white,
                    size: widget.size * 0.35,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _showConfirmation ? 'CONFIRM' : 'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}