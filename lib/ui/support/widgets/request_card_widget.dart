import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/app_theme.dart';
import 'status_badge_widget.dart';

class RequestCardWidget extends StatelessWidget {
  const RequestCardWidget({
    super.key,
    required this.request,
    required this.onTap,
    required this.onDelete,
  });

  final CcSupportRequestsRow request;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 15.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 7.0),
                spreadRadius: 3.0,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Request number, status badge, and menu
                Row(
                  children: [
                    Text(
                      request.requestNumber,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 12,
                        color: AppTheme.of(context).secondary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadgeWidget(
                      status: request.status,
                      compact: true,
                    ),
                    const Spacer(),
                    _buildActionsMenu(context),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  request.title,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.of(context).secondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Description preview
                if (request.description.isNotEmpty)
                  Text(
                    request.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.of(context).secondary.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),

                // Footer: Category, date, message count
                Row(
                  children: [
                    _buildCategoryChip(context),
                    const Spacer(),
                    if (request.messageCount > 0) ...[
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: AppTheme.of(context).secondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request.messageCount}',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          color: AppTheme.of(context).secondary.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.of(context).secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(request.updatedAt),
                      style: GoogleFonts.lexendDeca(
                        fontSize: 12,
                        color: AppTheme.of(context).secondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final categoryLabel = _getCategoryLabel(request.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        categoryLabel,
        style: GoogleFonts.lexendDeca(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.of(context).primary,
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.of(context).secondary.withValues(alpha: 0.6),
        size: 20,
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppTheme.of(context).error),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  color: AppTheme.of(context).error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'journey':
        return 'Journey';
      case 'community':
        return 'Community';
      case 'account':
        return 'Account';
      case 'technical':
        return 'Technical';
      case 'other':
      default:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
