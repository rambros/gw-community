import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/experience_moderation_repository.dart';
import 'package:gw_community/data/repositories/notification_repository.dart';
import 'package:gw_community/ui/community/group_moderation_page/view_model/group_moderation_view_model.dart';
import 'package:gw_community/ui/community/group_moderation_page/widgets/moderation_action_dialog.dart';
import 'package:gw_community/ui/community/group_moderation_page/widgets/moderation_experience_card.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:provider/provider.dart';

/// Page for moderating pending experiences in a group
/// Only accessible to ADMIN and GROUP_MANAGER roles
class GroupModerationPage extends StatelessWidget {
  static const routeName = 'groupModeration';
  static const routePath = '/groupModeration';

  final int groupId;
  final String groupName;

  const GroupModerationPage({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupModerationViewModel(
        repository: ExperienceModerationRepository(),
        notificationRepository: NotificationRepository(),
        groupId: groupId,
        currentUserUid: context.currentUserIdOrEmpty,
      )..loadPendingExperiences(),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.of(context).primary,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Consumer<GroupModerationViewModel>(
        builder: (context, viewModel, _) {
          final title = viewModel.hasPending ? 'Moderation (${viewModel.pendingCount})' : 'Moderation';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexendDeca(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500),
              ),
              Text(
                groupName,
                style: GoogleFonts.lexendDeca(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<GroupModerationViewModel>(
      builder: (context, viewModel, _) {
        // Loading state
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppTheme.of(context).primary));
        }

        // Error state
        if (viewModel.hasError) {
          return _buildErrorState(context, viewModel.errorMessage!);
        }

        // Empty state
        if (!viewModel.hasPending) {
          return _buildEmptyState(context);
        }

        // List of pending experiences
        return RefreshIndicator(
          onRefresh: viewModel.loadPendingExperiences,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.pendingExperiences.length,
            itemBuilder: (context, index) {
              final experience = viewModel.pendingExperiences[index];
              return ModerationExperienceCard(
                experience: experience,
                onApprove: () => _handleApprove(context, viewModel, experience),
                onReject: () => _handleReject(context, viewModel, experience),
                onSuggestRefinement: () => _handleSuggestRefinement(context, viewModel, experience),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: AppTheme.of(context).secondaryText),
          const SizedBox(height: 16),
          Text(
            'No Pending Experiences',
            style: AppTheme.of(
              context,
            ).titleMedium.override(font: GoogleFonts.lexendDeca(), fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up!',
            style: AppTheme.of(
              context,
            ).bodySmall.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.of(context).error),
            const SizedBox(height: 16),
            Text('Error', style: AppTheme.of(context).headlineSmall.override(font: GoogleFonts.lexendDeca())),
            const SizedBox(height: 8),
            Text(errorMessage, style: AppTheme.of(context).bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ========== ACTION HANDLERS ==========

  Future<void> _handleApprove(BuildContext context, GroupModerationViewModel viewModel, dynamic experience) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).primaryBackground,
        title: Text(
          'Approve Experience',
          style: AppTheme.of(context).headlineSmall.override(font: GoogleFonts.lexendDeca()),
        ),
        content: const Text('Are you sure you want to approve this experience?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.lexendDeca()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.of(context).primary),
            child: Text('Approve', style: GoogleFonts.lexendDeca(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await viewModel.approveExperienceCommand(experience);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Experience approved successfully', style: GoogleFonts.lexendDeca()),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context, GroupModerationViewModel viewModel, dynamic experience) async {
    final reason = await ModerationActionDialog.showReject(context);

    if (reason != null && context.mounted) {
      final success = await viewModel.notPublishExperienceCommand(experience, reason);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Experience status updated to Not Published', style: GoogleFonts.lexendDeca()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _handleSuggestRefinement(
    BuildContext context,
    GroupModerationViewModel viewModel,
    dynamic experience,
  ) async {
    final reason = await ModerationActionDialog.showSuggestRefinement(context);

    if (reason != null && context.mounted) {
      final success = await viewModel.suggestRefinementCommand(experience, reason);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refinement suggested', style: GoogleFonts.lexendDeca()),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
    }
  }
}
