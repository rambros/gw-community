import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Card widget displaying a pending experience with moderation actions
class ModerationExperienceCard extends StatelessWidget {
  final CcViewPendingExperiencesRow experience;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuggestRefinement;

  const ModerationExperienceCard({
    super.key,
    required this.experience,
    required this.onApprove,
    required this.onReject,
    required this.onSuggestRefinement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: AppTheme.of(context).primaryBackground,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: AppTheme.of(context).secondaryBackground, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorInfo(context),
            const SizedBox(height: 12),
            _buildExperienceText(context),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          imageUrl: experience.authorPhotoUrl,
          fullName: experience.authorDisplayName ?? experience.authorName ?? 'User',
          size: 36.0,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                experience.authorDisplayName ?? experience.authorName ?? 'Unknown User',
                style: AppTheme.of(
                  context,
                ).bodyMedium.override(font: GoogleFonts.lexendDeca(), fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              Text(
                timeago.format(experience.createdAt ?? DateTime.now()),
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).secondaryText,
                      fontSize: 12.0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceText(BuildContext context) {
    final text = experience.text ?? '';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text.isEmpty ? '(No text)' : text,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(), fontSize: 14.0),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Request Changes button
        OutlinedButton.icon(
          onPressed: onSuggestRefinement,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Refinement'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange.shade700,
            side: BorderSide(color: Colors.orange.shade700, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        const SizedBox(width: 8),

        // Reject button
        OutlinedButton.icon(
          onPressed: onReject,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Not Published'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade700, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        const SizedBox(width: 8),

        // Approve button
        ElevatedButton.icon(
          onPressed: onApprove,
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.of(context).primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ],
    );
  }
}
