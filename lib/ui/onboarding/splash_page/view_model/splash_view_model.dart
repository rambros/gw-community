import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/data/repositories/settings_repository.dart';
import 'package:gw_community/ui/auth/invite_accept_page/invite_accept_page.dart';
import 'package:gw_community/ui/auth/invite_accept_page/pending_invite.dart';
import 'package:gw_community/ui/auth/login_page/login_page.dart';
import 'package:gw_community/ui/home/home_page/home_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplash(BuildContext context) async {
    final appState = context.read<FFAppState>();

    try {
      final settingsRepo = SettingsRepository();
      await appState.loadAppConfig(settingsRepo);
    } catch (e) {
      debugPrint('Error loading app config: $e');
    }

    if (AppStateNotifier.instance.loggedIn) {
      try {
        await appState.loadGroupModuleConfig(HomeRepository());
      } catch (e) {
        debugPrint('Error loading group module config: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 4000));

    if (!context.mounted) return;

    AppStateNotifier.instance.stopShowingSplashImage();

    // Small delay so the router redirect (triggered by stopShowingSplashImage)
    // has time to process the PendingInvite.token before we navigate here.
    await Future.delayed(const Duration(milliseconds: 200));

    if (!context.mounted) return;

    // Already on invite page (navigated by _navigateToInvite or router redirect).
    final currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
    if (currentPath == InviteAcceptPage.routePath) return;

    // Pending invite arrived during splash but router redirect hasn't fired yet.
    final pendingToken = PendingInvite.token;
    if (pendingToken != null) {
      context.go('${InviteAcceptPage.routePath}?token=$pendingToken');
      return;
    }

    // Last resort: on cold start, getInitialLink() may have returned null
    // when _initDeepLinks() called it (iOS race condition where the URL
    // arrives via application:open:url:options: after Flutter initializes).
    // Check one final time right before navigating away from splash.
    try {
      final uri = await AppLinks().getInitialLink();
      if (!context.mounted) return;
      if (uri != null) {
        final isInvite = uri.scheme == 'gw' && uri.host == 'invite';
        final token = uri.queryParameters['token'];
        if (isInvite && token != null && token.isNotEmpty) {
          debugPrint('🔗 [splash-last-resort] found invite link: $uri');
          context.go('${InviteAcceptPage.routePath}?token=$token');
          return;
        }
      }
    } catch (_) {}

    if (!context.mounted) return;
    final loggedIn = AppStateNotifier.instance.loggedIn;
    if (loggedIn) {
      context.goNamed(HomePage.routeName);
    } else {
      context.goNamed(LoginPage.routeName);
    }
  }
}
