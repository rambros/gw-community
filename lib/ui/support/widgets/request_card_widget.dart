import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/support/widgets/status_badge_widget.dart';
import 'package:intl/intl.dart';

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
                // Header: Title and menu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.title,
                        style: GoogleFonts.lexendDeca(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.of(context).secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionsMenu(context),
                  ],
                ),
                const SizedBox(height: 12),

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
                    StatusBadgeWidget(
                      status: request.status,
                      compact: true,
                    ),
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
                      _formatDate(context, request.updatedAt),
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
                context.l10n.delete,
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

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return l10n.justNow;
    if (difference.inMinutes < 60) return l10n.minutesAgoShort(difference.inMinutes);
    if (difference.inHours < 24) return l10n.hoursAgoShort(difference.inHours);
    if (difference.inDays == 1) return l10n.yesterday;
    if (difference.inDays < 7) return l10n.daysAgoShort(difference.inDays);
    return DateFormat.MMMd(locale).format(date);
  }
}
