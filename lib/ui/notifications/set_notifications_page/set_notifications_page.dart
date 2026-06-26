import 'package:flutter/material.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/notifications/set_notifications_page/view_model/set_notifications_view_model.dart';
import 'package:provider/provider.dart';

class SetNotificationsPage extends StatelessWidget {
  const SetNotificationsPage({super.key});

  static const String routeName = 'setNotificationsPage';
  static const String routePath = '/setNotificationsPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SetNotificationsViewModel(),
      child: const _SetNotificationsView(),
    );
  }
}

class _SetNotificationsView extends StatelessWidget {
  const _SetNotificationsView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetNotificationsViewModel>();
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          'Notifications',
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
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _SectionHeader(title: 'Push Notifications', theme: theme),
                const SizedBox(height: 8),
                _NotificationTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts on your device even when the app is closed.',
                  value: viewModel.pushEnabled,
                  onChanged: viewModel.setPushEnabled,
                  theme: theme,
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'In-App Notifications', theme: theme),
                const SizedBox(height: 8),
                _NotificationTile(
                  icon: Icons.notifications_outlined,
                  title: 'In-App Notifications',
                  subtitle: 'Show the notification bell and alerts inside the app.',
                  value: viewModel.inAppEnabled,
                  onChanged: viewModel.setInAppEnabled,
                  theme: theme,
                ),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: theme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});
  final String title;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: theme.labelLarge.override(
          color: theme.secondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Icon(icon, color: theme.primary, size: 28),
        title: Text(
          title,
          style: theme.bodyMedium.override(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.primary,
        activeThumbColor: Colors.white,
      ),
    );
  }
}
