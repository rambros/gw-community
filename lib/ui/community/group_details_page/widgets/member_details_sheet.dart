import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class MemberDetailsSheet extends StatelessWidget {
  final CcMembersRow member;

  const MemberDetailsSheet({
    super.key,
    required this.member,
  });

  String get _displayName {
    if (member.hideLastName == true) {
      return member.firstName ?? member.displayName ?? 'Unknown';
    }
    final fullName = '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    return fullName.isNotEmpty ? fullName : (member.displayName ?? 'Unknown');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.5,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member Details',
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.lexendDeca(),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Avatar
                  UserAvatar(
                    imageUrl: member.photoUrl,
                    fullName: _displayName,
                    size: 80,
                  ),
                  const SizedBox(height: 16.0),
                  // Name
                  Text(
                    _displayName,
                    style: AppTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.lexendDeca(),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  // Info cards
                  if (member.email != null) ...[
                    _InfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: member.email!,
                      context: context,
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  if (member.bio != null && member.bio!.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.info_outline,
                      label: 'Bio',
                      value: member.bio!,
                      context: context,
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  if (member.country != null && member.country!.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Country',
                      value: member.country!,
                      context: context,
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  const SizedBox(height: 24.0),
                  // Remove button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmRemoveMember(context),
                      icon: Icon(
                        Icons.person_remove_outlined,
                        color: Colors.red.shade700,
                      ),
                      label: Text(
                        'Remove from Group',
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: Colors.red.shade700,
                            ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveMember(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove "$_displayName" from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(alertContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final viewModel = context.read<GroupDetailsViewModel>();
      final success = await viewModel.removeMember(member.authUserId!);

      if (context.mounted) {
        Navigator.pop(context); // Close details sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Member removed successfully' : 'Failed to remove member',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final BuildContext context;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.of(context).secondary,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.lexendDeca(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
