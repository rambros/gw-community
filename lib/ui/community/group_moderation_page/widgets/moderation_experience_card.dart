import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';

/// Card widget displaying an experience with moderation actions
/// Shows status badge and dynamic action buttons based on current status
/// Synced with admin portal moderation workflow
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
    final status = experience.moderationStatus ?? 'awaiting_approval';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorInfo(context),
            const SizedBox(height: 12),
            _buildStatusBadge(context),
            const SizedBox(height: 12),
            _buildExperienceText(context),
            if (_hasModerationReason) ...[
              const SizedBox(height: 12),
              _buildModerationReason(context),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    final dateStr = _formatDate(experience.createdAt);
    final groupName = experience.groupName ?? '';

    return Row(
      children: [
        UserAvatar(
          imageUrl: experience.authorPhotoUrl,
          fullName: experience.authorDisplayName ?? experience.authorName ?? 'User',
          size: 40.0,
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
                ).bodyMedium.override(font: GoogleFonts.lexendDeca(), fontWeight: FontWeight.w600, fontSize: 15.0),
              ),
              const SizedBox(height: 2),
              Text(
                groupName.isNotEmpty ? '$dateStr  •  $groupName' : dateStr,
                style: GoogleFonts.lexendDeca(
                  color: Colors.grey.shade600,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = experience.moderationStatus ?? 'awaiting_approval';
    final statusLabel = _getStatusLabel(status);
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusLabel,
        style: GoogleFonts.openSans(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExperienceText(BuildContext context) {
    final text = experience.text ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text.isEmpty ? '(No text)' : text,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(), fontSize: 14.0),
      ),
    );
  }

  bool get _hasModerationReason {
    final reason = experience.moderationReason;
    return reason != null && reason.isNotEmpty;
  }

  Widget _buildModerationReason(BuildContext context) {
    final status = experience.moderationStatus ?? 'awaiting_approval';
    final reasonLabel = status == 'changes_requested' ? 'Feedback' : 'Reason';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                reasonLabel,
                style: GoogleFonts.lexendDeca(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            experience.moderationReason ?? '',
            style: GoogleFonts.inter(
              color: Colors.orange.shade900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = experience.moderationStatus ?? 'awaiting_approval';

    // Dynamic actions based on status - synced with admin portal
    switch (status) {
      case 'awaiting_approval':
        return _buildAwaitingApprovalActions(context);
      case 'approved':
        return _buildApprovedActions(context);
      case 'rejected':
        return _buildRejectedActions(context);
      case 'changes_requested':
        return _buildChangesRequestedActions(context);
      default:
        return _buildAwaitingApprovalActions(context);
    }
  }

  /// Actions for awaiting_approval: Refinement, Not Published, Approve
  Widget _buildAwaitingApprovalActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildRefinementButton(context),
        _buildRejectButton(context),
        _buildApproveButton(context),
      ],
    );
  }

  /// Actions for approved: Reject (revert)
  Widget _buildApprovedActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildRejectButton(context, label: 'Revert'),
      ],
    );
  }

  /// Actions for rejected: Approve (revert)
  Widget _buildRejectedActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildApproveButton(context, label: 'Approve'),
      ],
    );
  }

  /// Actions for changes_requested: Refinement, Reject, Approve
  Widget _buildChangesRequestedActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildRefinementButton(context),
        _buildRejectButton(context),
        _buildApproveButton(context),
      ],
    );
  }

  Widget _buildRefinementButton(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onSuggestRefinement,
        icon: const Icon(Icons.edit_outlined, size: 16),
        label: const Text('Refine'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange.shade700,
          side: BorderSide(color: Colors.orange.shade700, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildRejectButton(BuildContext context, {String label = 'Reject'}) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onReject,
        icon: const Icon(Icons.close, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade700, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildApproveButton(BuildContext context, {String label = 'Approve'}) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onApprove,
        icon: const Icon(Icons.check, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.of(context).primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'awaiting_approval':
        return 'Awaiting Approval';
      case 'pending':
        return 'In Reflection';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Not Published';
      case 'changes_requested':
        return 'Refinement Suggested';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF2E7D32); // Dark green for better contrast
      case 'rejected':
        return const Color(0xFFD32F2F); // Dark red for better contrast
      case 'changes_requested':
        return const Color(0xFFE65100); // Dark orange for better contrast
      case 'awaiting_approval':
      case 'pending':
      default:
        return const Color(0xFF1565C0); // Dark blue for better contrast
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'changes_requested':
        return Icons.edit;
      case 'awaiting_approval':
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }
}
