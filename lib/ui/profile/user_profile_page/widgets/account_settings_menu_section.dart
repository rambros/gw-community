import 'package:flutter/material.dart';
import 'package:gw_community/data/models/enums/user_role.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/community_guidelines_edit_page/community_guidelines_edit_page.dart';
import 'package:gw_community/ui/core/widgets/screen_hint.dart';
import 'package:gw_community/ui/profile/user_profile_page/widgets/language_picker.dart';
import 'package:gw_community/ui/profile/user_profile_page/widgets/profile_menu_item_widget.dart';
import 'package:gw_community/ui/profile/view_as_user_page/view_as_user_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuItemWidget(
          text: l10n.editProfile,
          onTap: () async {
            context.pushNamed(UserEditProfilePage.routeName);
          },
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: l10n.language,
            trailingText: currentLanguageLabel(context),
            onTap: () => showLanguagePicker(context),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: l10n.changePassword,
            onTap: () async {
              context.pushNamed(ChangePasswordPage.routeName);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: l10n.setNotifications,
            onTap: () async {
              context.pushNamed('setNotificationsPage');
            },
          ),
        ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
            child: ProfileMenuItemWidget(
              text: l10n.viewAsUser,
              onTap: () async {
                context.pushNamed(ViewAsUserPage.routeName);
              },
            ),
          ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
            child: ProfileMenuItemWidget(
              text: l10n.editGuidelines,
              onTap: () async {
                context.pushNamed(CommunityGuidelinesEditPage.routeName);
              },
            ),
          ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
            child: ProfileMenuItemWidget(
              text: l10n.resetTips,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('hint_journey');
                await prefs.remove('hint_community');
                await prefs.remove('hint_library');
                HintResetNotifier.instance.resetAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.tipsReset)),
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}
