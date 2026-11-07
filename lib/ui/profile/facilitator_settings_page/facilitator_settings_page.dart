import 'package:flutter/material.dart';
import 'package:gw_community/domain/community/facilitator_group_settings.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/profile/facilitator_settings_page/view_model/facilitator_settings_view_model.dart';
import 'package:provider/provider.dart';

class FacilitatorSettingsPage extends StatelessWidget {
  const FacilitatorSettingsPage({super.key});

  static const String routeName = 'facilitatorSettingsPage';
  static const String routePath = '/facilitatorSettingsPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FacilitatorSettingsViewModel()..load(),
      child: const _FacilitatorSettingsView(),
    );
  }
}

class _FacilitatorSettingsView extends StatelessWidget {
  const _FacilitatorSettingsView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FacilitatorSettingsViewModel>();
    final theme = AppTheme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          l10n.facilitatorSettings,
          style: theme.headlineMedium.override(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                Text(
                  l10n.facilitatorSettingsIntro,
                  style: theme.bodyMedium.override(color: theme.secondary),
                ),
                const SizedBox(height: 16),
                for (final group in viewModel.groups) ...[
                  _GroupCard(group: group, showApplyToAll: viewModel.groups.length > 1),
                  const SizedBox(height: 16),
                ],
                if (viewModel.errorMessage != null)
                  Text(
                    l10n.couldNotSaveFacilitatorSettings,
                    style: TextStyle(color: theme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.showApplyToAll});

  final FacilitatorGroupSettings group;
  final bool showApplyToAll;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = context.l10n;
    final viewModel = context.read<FacilitatorSettingsViewModel>();

    return Material(
      color: theme.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.alternate),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              group.groupName,
              style: theme.titleMedium.override(
                color: theme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _Switch(
              title: l10n.notifyNewExperiences,
              subtitle: l10n.notifyNewExperiencesSubtitle,
              value: group.notifyNewExperiences,
              onChanged: (value) => viewModel.update(group.copyWith(notifyNewExperiences: value)),
            ),
            _Switch(
              title: l10n.emailEachExperience,
              subtitle: l10n.emailEachExperienceSubtitle,
              value: group.emailEachExperience,
              onChanged: (value) => viewModel.update(group.copyWith(emailEachExperience: value)),
            ),
            _Switch(
              title: l10n.notifyMessagesForYou,
              subtitle: l10n.notifyMessagesForYouSubtitle,
              value: group.notifyMessages,
              onChanged: (value) => viewModel.update(group.copyWith(notifyMessages: value)),
            ),
            _Switch(
              title: l10n.emailMemberMessage,
              subtitle: l10n.emailMemberMessageSubtitle,
              value: group.emailMemberMessage,
              onChanged: (value) => viewModel.update(group.copyWith(emailMemberMessage: value)),
            ),
            _Switch(
              title: l10n.emailDailySummary,
              subtitle: l10n.emailDailySummarySubtitle,
              value: group.emailDailySummary,
              onChanged: (value) => viewModel.update(group.copyWith(emailDailySummary: value)),
            ),
            _Switch(
              title: l10n.emailWeeklySummary,
              subtitle: l10n.emailWeeklySummarySubtitle,
              value: group.emailWeeklySummary,
              onChanged: (value) => viewModel.update(group.copyWith(emailWeeklySummary: value)),
            ),
            if (showApplyToAll)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => viewModel.applyToAll(group),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primary,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    l10n.applySettingsToAllGroups,
                    style: theme.bodyMedium.override(
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.bodyMedium.override(
          color: theme.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle, style: theme.bodySmall.override(color: theme.secondaryText)),
      value: value,
      activeTrackColor: theme.primary,
      activeThumbColor: Colors.white,
      onChanged: onChanged,
    );
  }
}
