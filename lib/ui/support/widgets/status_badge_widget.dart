import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadgeWidget extends StatelessWidget {
  const StatusBadgeWidget({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 12 : 16,
            color: config.textColor,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            config.label,
            style: GoogleFonts.lexendDeca(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'open':
        return _StatusConfig(
          label: 'Open',
          icon: Icons.fiber_new,
          backgroundColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1976D2),
        );
      case 'in_progress':
        return _StatusConfig(
          label: 'Being Reviewed',
          icon: Icons.hourglass_empty,
          backgroundColor: const Color(0xFFFFF3CD),
          textColor: const Color(0xFFB8860B),
        );
      case 'awaiting_user':
        return _StatusConfig(
          label: 'Needs Your Response',
          icon: Icons.reply,
          backgroundColor: const Color(0xFFFFE0B2),
          textColor: const Color(0xFFE65100),
        );
      case 'resolved':
        return _StatusConfig(
          label: 'Completed',
          icon: Icons.check_circle_outline,
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF388E3C),
        );
      default:
        return _StatusConfig(
          label: status,
          icon: Icons.help_outline,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade700,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}
