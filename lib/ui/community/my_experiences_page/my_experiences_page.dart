import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/sharing_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/my_experiences_page/view_model/my_experiences_view_model.dart';
import 'package:gw_community/ui/community/sharing_edit_page/sharing_edit_page.dart';
import 'package:gw_community/ui/community/sharing_view_page/sharing_view_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Page that lists all experiences created by the current user
/// with actions to view, edit, and delete
class MyExperiencesPage extends StatelessWidget {
  const MyExperiencesPage({super.key});

  static const String routeName = 'myExperiencesPage';
  static const String routePath = '/myExperiencesPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyExperiencesViewModel(
        repository: context.read<SharingRepository>(),
        currentUserId: context.currentUserIdOrEmpty,
      )..loadExperiences(),
      child: const _MyExperiencesPageContent(),
    );
  }
}

class _MyExperiencesPageContent extends StatelessWidget {
  const _MyExperiencesPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyExperiencesViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30.0),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Experiences',
          style: AppTheme.of(
            context,
          ).bodyMedium.override(font: GoogleFonts.lexendDeca(), color: Colors.white, fontSize: 20.0),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, MyExperiencesViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(child: SpinKitRipple(color: AppTheme.of(context).primary, size: 50.0));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.of(context).error),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTheme.of(
                  context,
                ).bodyMedium.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => viewModel.loadExperiences(), child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (viewModel.experiences.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 64, color: AppTheme.of(context).cadetGrey),
            const SizedBox(height: 16),
            Text(
              'No experiences yet',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).cadetGrey,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start sharing your experiences with the community!',
              textAlign: TextAlign.center,
              style: AppTheme.of(
                context,
              ).bodySmall.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).cadetGrey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadExperiences(),
      color: AppTheme.of(context).primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: viewModel.experiences.length,
        itemBuilder: (context, index) {
          final experience = viewModel.experiences[index];
          return _ExperienceCard(
            experience: experience,
            onView: () => _navigateToView(context, experience),
            onEdit: () => _navigateToEdit(context, experience),
            onDelete: () => _confirmDelete(context, viewModel, experience),
            onPublish:
                experience.moderationStatus == 'draft' ? () => _confirmPublish(context, viewModel, experience) : null,
          );
        },
      ),
    );
  }

  void _navigateToView(BuildContext context, CcViewSharingsUsersRow experience) {
    context.pushNamed(
      SharingViewPage.routeName,
      queryParameters: {'sharingId': serializeParam(experience.id, ParamType.int)}.withoutNulls,
    );
  }

  void _navigateToEdit(BuildContext context, CcViewSharingsUsersRow experience) {
    context.pushNamed(SharingEditPage.routeName, extra: {'sharingRow': experience});
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MyExperiencesViewModel viewModel,
    CcViewSharingsUsersRow experience,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => WebViewAware(
        child: AlertDialog(
          title: const Text('Delete Experience'),
          content: const Text('Are you sure you want to delete this experience? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: AppTheme.of(context).secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.deleteExperience(experience.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Experience deleted successfully'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    }
  }

  Future<void> _confirmPublish(
    BuildContext context,
    MyExperiencesViewModel viewModel,
    CcViewSharingsUsersRow experience,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => WebViewAware(
        child: AlertDialog(
          title: const Text('Publish Experience'),
          content: const Text(
            'Are you sure you want to publish this experience? It will be sent for moderation review.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: AppTheme.of(context).secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Publish', style: TextStyle(color: AppTheme.of(context).primary)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.publishExperience(experience.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Experience published successfully'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    }
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.experience,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
  });

  final CcViewSharingsUsersRow experience;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;

  bool get isDraft => experience.moderationStatus == 'draft';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(blurRadius: 15.0, color: Color(0x1A000000), offset: Offset(0.0, 7.0), spreadRadius: 3.0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar, display name and actions menu
            InkWell(
              onTap: onView,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    UserAvatar(imageUrl: experience.photoUrl, fullName: experience.fullName, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience.displayName ?? experience.fullName ?? 'User',
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppTheme.of(context).secondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildVisibilityText(context),
                        ],
                      ),
                    ),
                    // Actions popup menu
                    _buildActionsMenu(context),
                  ],
                ),
              ),
            ),

            // Moderation status badge (below header)
            _buildModerationStatus(context),

            // Text content
            if (experience.text != null && experience.text!.trim().isNotEmpty)
              InkWell(
                onTap: onView,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.text!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: AppTheme.of(context).secondary,
                              fontSize: 14,
                            ),
                      ),
                      if (experience.moderationStatus == 'rejected' ||
                          experience.moderationStatus == 'changes_requested')
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (experience.moderationReason != null && experience.moderationReason!.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    experience.moderationReason!,
                                    style: AppTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.lexendDeca(),
                                          color: AppTheme.of(context).secondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              Text(
                                experience.moderationStatus == 'rejected'
                                    ? 'You’re welcome to revise and share again whenever you feel ready.'
                                    : 'A few suggestions were shared to help refine your experience.\nWhen ready, review them and tap “Update & Resubmit”.',
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: AppTheme.of(context).secondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppTheme.of(context).secondary),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView();
            break;
          case 'edit':
            onEdit();
            break;
          case 'publish':
            onPublish?.call();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 20, color: AppTheme.of(context).secondary),
              const SizedBox(width: 12),
              Text('View', style: GoogleFonts.lexendDeca(fontSize: 14, color: AppTheme.of(context).secondary)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: AppTheme.of(context).primary),
              const SizedBox(width: 12),
              Text(
                experience.moderationStatus == 'draft' ? 'Submit' : 'Update',
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  color: experience.moderationStatus == 'draft'
                      ? AppTheme.of(context).primary
                      : (experience.moderationStatus == 'rejected' ||
                              experience.moderationStatus == 'changes_requested')
                          ? AppTheme.of(context).primary
                          : AppTheme.of(context).primary,
                ),
              ),
            ],
          ),
        ),
        if (isDraft && onPublish != null)
          PopupMenuItem<String>(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.publish, size: 20, color: AppTheme.of(context).success),
                const SizedBox(width: 12),
                Text('Publish', style: GoogleFonts.lexendDeca(fontSize: 14, color: AppTheme.of(context).success)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppTheme.of(context).error),
              const SizedBox(width: 12),
              Text('Delete', style: GoogleFonts.lexendDeca(fontSize: 14, color: AppTheme.of(context).error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityText(BuildContext context) {
    final visibility = experience.visibility;
    final groupName = experience.groupName;

    String text;
    if (visibility == 'everyone') {
      text = 'Visible for everyone';
    } else if (groupName != null && groupName.isNotEmpty) {
      text = 'Visible only for $groupName';
    } else {
      text = 'Group only';
    }

    return Text(
      text,
      style: AppTheme.of(context).bodySmall.override(
            font: GoogleFonts.lexendDeca(),
            color: AppTheme.of(context).secondary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildModerationStatus(BuildContext context) {
    final status = experience.moderationStatus;

    // Don't show for approved experiences
    if (status == null || status == 'approved') {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'draft':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        icon = Icons.edit_note;
        label = 'In Reflection';
        break;
      case 'awaiting_approval':
      case 'pending':
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFFB8860B);
        icon = Icons.hourglass_empty;
        label = 'Awaiting Approval';
        break;
      case 'rejected':
        backgroundColor = AppTheme.of(context).error.withValues(alpha: 0.15);
        textColor = AppTheme.of(context).error;
        icon = Icons.cancel_outlined;
        label = 'Not Published';
        break;
      case 'changes_requested':
        backgroundColor = AppTheme.of(context).copperRed.withValues(alpha: 0.15);
        textColor = AppTheme.of(context).copperRed;
        icon = Icons.edit_note;
        label = 'Refinement Suggested';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lexendDeca(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
