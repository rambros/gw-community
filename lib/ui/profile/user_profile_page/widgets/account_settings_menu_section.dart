import 'package:flutter/material.dart';
import 'package:gw_community/data/models/enums/user_role.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/community_guidelines_edit_page/community_guidelines_edit_page.dart';
import 'package:gw_community/ui/profile/user_profile_page/widgets/profile_menu_item_widget.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class AccountSettingsMenuSection extends StatelessWidget {
  const AccountSettingsMenuSection({
    super.key,
    required this.onResetOnboarding,
    this.userProfile,
  });

  final VoidCallback onResetOnboarding;
  final CcMembersRow? userProfile;

  bool get isAdmin {
    final roles = userProfile?.userRole ?? [];
    return roles.hasAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuItemWidget(
          text: 'Edit Profile',
          onTap: () async {
            context.pushNamed(UserEditProfilePage.routeName);
          },
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'Change Password',
            onTap: () async {
              context.pushNamed(ChangePasswordPage.routeName);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'Set Notifications',
            onTap: () async {
              // No action in original code
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'Reset Onboarding',
            onTap: onResetOnboarding,
          ),
        ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
            child: ProfileMenuItemWidget(
              text: 'Edit Guidelines',
              onTap: () async {
                context.pushNamed(CommunityGuidelinesEditPage.routeName);
              },
            ),
          ),
      ],
    );
  }
}
