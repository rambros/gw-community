import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gw_community/data/models/structs/index.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/routing/portal_app_links.dart';
import 'package:gw_community/ui/community/community_guidelines_edit_page/community_guidelines_edit_page.dart';
import 'package:gw_community/ui/community/community_guidelines_page/community_guidelines_page.dart';
import 'package:gw_community/ui/community/group_details_page/member_management_page/member_management_page.dart';
import 'package:gw_community/ui/community/group_moderation_page/group_moderation_page.dart';
import 'package:gw_community/ui/core/nav_bar/nav_bar_page.dart';
import 'package:gw_community/ui/journey/journey_list_page/journey_list_page.dart';
import 'package:gw_community/ui/notifications/set_notifications_page/set_notifications_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

export 'package:go_router/go_router.dart';

export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  AppAuthUser? initialUser;
  AppAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Stays set until the router actually reaches this location.
  /// Prevents `/` → Home from winning the race against a just-opened event link.
  String? pendingPortalLocation;

  void setPendingPortalLocation(String location) {
    pendingPortalLocation = location;
  }

  void clearPendingPortalLocation() {
    pendingPortalLocation = null;
  }

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  bool pendingPasswordRecovery = false;

  void update(AppAuthUser newUser) {
    final shouldUpdate = user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }

}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: false,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.loggedIn ? const NavBarPage() : const LoginPage(),
      redirect: (context, state) {
        if (appStateNotifier.loading) {
          return null;
        }

        final loggedIn = appStateNotifier.loggedIn;
        final publicRoutes = [
          '/',
          SplashPage.routePath,
          LoginPage.routePath,
          ForgotPasswordPage.routePath,
        ];
        final isPublicRoute = publicRoutes.contains(state.uri.path);

        // Auth landing URLs are handled in main.dart, not as in-app routes.
        if (state.uri.path.startsWith('/access-link') ||
            state.uri.path.startsWith('/login-callback')) {
          return LoginPage.routePath;
        }

        if (!loggedIn && !isPublicRoute) {
          debugPrint('ROUTER: User not logged in and on protected page ${state.uri.path}. Redirecting to Login.');
          appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
          return LoginPage.routePath;
        }

        if (loggedIn && appStateNotifier.pendingPasswordRecovery) {
          debugPrint('ROUTER: Password recovery in progress — redirecting to ChangePasswordPage.');
          return ChangePasswordPage.routePath;
        }

        final pendingPortal = appStateNotifier.pendingPortalLocation;
        if (loggedIn && pendingPortal != null) {
          final pendingPath = Uri.tryParse(pendingPortal)?.path ?? pendingPortal;
          if (state.uri.path == pendingPath) {
            appStateNotifier.clearPendingPortalLocation();
            appStateNotifier.clearRedirectLocation();
            return null;
          }
          final onEntryRoute = isPublicRoute || state.uri.path == HomePage.routePath;
          if (onEntryRoute) {
            debugPrint('ROUTER: Honoring pending portal link $pendingPortal (was ${state.uri.path})');
            return pendingPortal;
          }
        }

        if (loggedIn && appStateNotifier.hasRedirect()) {
          final redirectLocation = appStateNotifier.getRedirectLocation();
          appStateNotifier.clearRedirectLocation();
          return redirectLocation;
        }

        if (loggedIn && isPublicRoute) {
          debugPrint('ROUTER: User logged in and on public route ${state.uri.path}. Redirecting to Home.');
          return HomePage.routePath;
        }

        return null;
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) {
            if (appStateNotifier.loading) {
              return const SplashPage();
            }
            return appStateNotifier.loggedIn ? const NavBarPage() : const LoginPage();
          },
        ),
        FFRoute(
            name: SplashPage.routeName, path: SplashPage.routePath, builder: (context, params) => const SplashPage()),
        FFRoute(name: LoginPage.routeName, path: LoginPage.routePath, builder: (context, params) => const LoginPage()),
        FFRoute(
          name: UserCreateProfilePage.routeName,
          path: UserCreateProfilePage.routePath,
          builder: (context, params) => const UserCreateProfilePage(),
        ),
        FFRoute(
          name: ForgotPasswordPage.routeName,
          path: ForgotPasswordPage.routePath,
          builder: (context, params) => const ForgotPasswordPage(),
        ),
        FFRoute(
          name: HomePage.routeName,
          path: HomePage.routePath,
          builder: (context, params) => params.isEmpty ? const NavBarPage(initialPage: 'homePage') : const HomePage(),
        ),
        FFRoute(
          name: LearnListPage.routeName,
          path: LearnListPage.routePath,
          builder: (context, params) => LearnListPage(
            journeyId: params.getParam('journeyId', ParamType.int),
            groupId: params.getParam('groupId', ParamType.int),
            customTitle: params.getParam('customTitle', ParamType.String),
            autofocusSearch: params.getParam('autofocusSearch', ParamType.bool) ?? false,
          ),
        ),
        FFRoute(
          name: LibraryHubPage.routeName,
          path: LibraryHubPage.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(initialPage: 'learnListPage')
              : const LibraryHubPage(),
        ),
        FFRoute(
          name: PortalEventsPage.routeName,
          path: PortalEventsPage.routePath,
          builder: (context, params) => PortalEventsPage(
            dashboardGroupId: params.getParam('dashboardGroupId', ParamType.int) ?? 1,
          ),
        ),
        FFRoute(
          name: PortalCatalogPage.routeName,
          path: PortalCatalogPage.routePath,
          builder: (context, params) {
            final kindName = params.getParam('kind', ParamType.String) ?? PortalCatalogKind.messages.name;
            final kind = PortalCatalogKind.values.firstWhere(
              (value) => value.name == kindName,
              orElse: () => PortalCatalogKind.messages,
            );
            return PortalCatalogPage(kind: kind);
          },
        ),
        FFRoute(
          name: PortalEventDetailPage.routeName,
          path: PortalEventDetailPage.routePath,
          builder: (context, params) => PortalEventDetailPage(
            eventId: PortalAppLinks.parseId(params.state.uri.queryParameters['id']) ??
                params.getParam('id', ParamType.int) ??
                0,
          ),
        ),
        FFRoute(
          name: 'portalEventLink',
          path: PortalAppLinks.eventPath,
          builder: (context, params) => NavBarPage(
            initialPage: 'learnListPage',
            page: PortalEventDetailPage(
              eventId: PortalAppLinks.parseId(params.state.uri.queryParameters['id']) ??
                  params.getParam('id', ParamType.int) ??
                  0,
            ),
          ),
        ),
        FFRoute(
          name: ContentViewPage.routeName,
          path: ContentViewPage.routePath,
          builder: (context, params) => ContentViewPage(
            contentId: PortalAppLinks.parseId(params.state.uri.queryParameters['id']) ??
                params.getParam('id', ParamType.int) ??
                0,
            previewRow: params.getParam<ViewContentRow>('previewRow', ParamType.SupabaseRow),
          ),
        ),
        FFRoute(
          name: 'portalContentLink',
          path: PortalAppLinks.contentPath,
          builder: (context, params) => NavBarPage(
            initialPage: 'learnListPage',
            page: ContentViewPage(
              contentId: PortalAppLinks.parseId(params.state.uri.queryParameters['id']) ??
                  params.getParam('id', ParamType.int) ??
                  0,
            ),
          ),
        ),
        FFRoute(
          name: JourneysListPage.routeName,
          path: JourneysListPage.routePath,
          builder: (context, params) => const JourneysListPage(),
        ),
        FFRoute(
          name: UserProfilePage.routeName,
          path: UserProfilePage.routePath,
          builder: (context, params) =>
              params.isEmpty ? const NavBarPage(initialPage: 'userProfilePage') : const UserProfilePage(),
        ),
        FFRoute(
          name: EventDetailsPage.routeName,
          path: EventDetailsPage.routePath,
          builder: (context, params) => EventDetailsPage(
            eventRow: params.getParam<CcEventsRow>('eventRow', ParamType.SupabaseRow),
            groupId: params.getParam('groupId', ParamType.int),
          ),
        ),
        FFRoute(
          name: UserEditProfilePage.routeName,
          path: UserEditProfilePage.routePath,
          builder: (context, params) => const UserEditProfilePage(),
        ),
        FFRoute(
          name: ChangePasswordPage.routeName,
          path: ChangePasswordPage.routePath,
          builder: (context, params) => const ChangePasswordPage(),
        ),
        FFRoute(
          name: UnsplashPage.routeName,
          path: UnsplashPage.routePath,
          builder: (context, params) => const UnsplashPage(),
        ),
        FFRoute(
          name: CommunityPage.routeName,
          path: CommunityPage.routePath,
          builder: (context, params) =>
              params.isEmpty ? const NavBarPage(initialPage: 'communityPage') : const CommunityPage(),
        ),
        FFRoute(
          name: ExperienceViewPage.routeName,
          path: ExperienceViewPage.routePath,
          builder: (context, params) =>
              ExperienceViewPage(experienceId: params.getParam('experienceId', ParamType.int)),
        ),
        FFRoute(
          name: ExperienceAddPage.routeName,
          path: ExperienceAddPage.routePath,
          builder: (context, params) => ExperienceAddPage(
            groupId: params.getParam('groupId', ParamType.int),
            groupName: params.getParam('groupName', ParamType.String),
            privacy: params.getParam('privacy', ParamType.String),
          ),
        ),
        FFRoute(
          name: ExperienceEditPage.routeName,
          path: ExperienceEditPage.routePath,
          builder: (context, params) => ExperienceEditPage(
            experienceRow: params.getParam<CcViewSharingsUsersRow>('experienceRow', ParamType.SupabaseRow),
          ),
        ),
        FFRoute(
          name: GroupDetailsPage.routeName,
          path: GroupDetailsPage.routePath,
          builder: (context, params) =>
              GroupDetailsPage(groupRow: params.getParam<CcGroupsRow>('groupRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: GroupInvitationPage.routeName,
          path: GroupInvitationPage.routePath,
          builder: (context, params) =>
              GroupInvitationPage(groupRow: params.getParam<CcGroupsRow>('groupRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: EventAddPage.routeName,
          path: EventAddPage.routePath,
          builder: (context, params) => EventAddPage(
            groupId: params.getParam('groupId', ParamType.int),
            groupName: params.getParam('groupName', ParamType.String),
          ),
        ),
        FFRoute(
          name: EventEditPage.routeName,
          path: EventEditPage.routePath,
          builder: (context, params) =>
              EventEditPage(eventRow: params.getParam<CcEventsRow>('eventRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: JourneyStepDetailsPage.routeName,
          path: JourneyStepDetailsPage.routePath,
          builder: (context, params) => JourneyStepDetailsPage(journeyId: params.getParam('journeyId', ParamType.int)),
        ),
        FFRoute(
          name: StepDetailsPage.routeName,
          path: StepDetailsPage.routePath,
          builder: (context, params) =>
              StepDetailsPage(userStepRow: params.getParam<CcViewUserStepsRow>('userStepRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: StepTextViewPage.routeName,
          path: StepTextViewPage.routePath,
          builder: (context, params) => StepTextViewPage(
            stepTextTitle: params.getParam('stepTextTitle', ParamType.String),
            stepTextContent: params.getParam('stepTextContent', ParamType.String),
            activityId: params.getParam('activityId', ParamType.int),
          ),
        ),
        FFRoute(
          name: StepAudioPlayerPage.routeName,
          path: StepAudioPlayerPage.routePath,
          builder: (context, params) => StepAudioPlayerPage(
            stepAudioUrl: params.getParam('stepAudioUrl', ParamType.String),
            audioTitle: params.getParam('audioTitle', ParamType.String),
            audioArt: params.getParam('audioArt', ParamType.String),
            typeStep: params.getParam('typeStep', ParamType.String),
            activityId: params.getParam('activityId', ParamType.int),
            transcript: params.getParam('transcript', ParamType.String),
            animationUrl: params.getParam('animationUrl', ParamType.String),
            animationMediaType: params.getParam('animationMediaType', ParamType.String),
          ),
        ),
        FFRoute(
          name: StepVideoPlayerPage.routeName,
          path: StepVideoPlayerPage.routePath,
          builder: (context, params) => StepVideoPlayerPage(
            videoUrl: params.getParam('videoUrl', ParamType.String),
            videoTitle: params.getParam('videoTitle', ParamType.String),
            typeStep: params.getParam('typeStep', ParamType.String),
            activityId: params.getParam('activityId', ParamType.int),
          ),
        ),
        FFRoute(
          name: StepJournalPage.routeName,
          path: StepJournalPage.routePath,
          builder: (context, params) => StepJournalPage(
              activityRow: params.getParam<CcViewUserActivitiesRow>('activityRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: JourneyPage.routeName,
          path: JourneyPage.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(initialPage: 'journeyPage')
              : NavBarPage(
                  initialPage: 'journeyPage',
                  page: JourneyPage(journeyId: params.getParam('journeyId', ParamType.int)),
                ),
        ),
        FFRoute(
          name: JourneyListPage.routeName,
          path: JourneyListPage.routePath,
          builder: (context, params) => const NavBarPage(initialPage: 'journeyPage'),
        ),
        FFRoute(
          name: GroupAddPage.routeName,
          path: GroupAddPage.routePath,
          builder: (context, params) => const GroupAddPage(),
        ),
        FFRoute(
          name: GroupEditPage.routeName,
          path: GroupEditPage.routePath,
          builder: (context, params) =>
              GroupEditPage(groupRow: params.getParam<CcGroupsRow>('groupRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: AnnouncementAddPage.routeName,
          path: AnnouncementAddPage.routePath,
          builder: (context, params) => AnnouncementAddPage(
            groupId: params.getParam('groupId', ParamType.int),
            groupName: params.getParam('groupName', ParamType.String),
            privacy: params.getParam('privacy', ParamType.String),
            groupMembers: params.getParam<CcMembersRow>(
                  'groupMembers', ParamType.SupabaseRow,
                  isList: true) ??
                [],
          ),
        ),
        FFRoute(
          name: AnnouncementEditPage.routeName,
          path: AnnouncementEditPage.routePath,
          builder: (context, params) => AnnouncementEditPage(
            experienceRow: params.getParam<CcViewNotificationsUsersRow>('experienceRow', ParamType.SupabaseRow),
          ),
        ),
        FFRoute(
          name: AnnouncementViewPage.routeName,
          path: AnnouncementViewPage.routePath,
          builder: (context, params) => AnnouncementViewPage(
            announcementId: params.getParam('announcementId', ParamType.int),
            groupModerators: params.getParam<int>('groupModerators', ParamType.int, isList: true),
          ),
        ),
        FFRoute(
          name: UserJournalListPage.routeName,
          path: UserJournalListPage.routePath,
          builder: (context, params) => const UserJournalListPage(),
        ),
        FFRoute(
          name: UserJournalViewPage.routeName,
          path: UserJournalViewPage.routePath,
          builder: (context, params) =>
              UserJournalViewPage(userActivitiesId: params.getParam('userActivitiesId', ParamType.int)),
        ),
        FFRoute(
          name: UserJournalEditPage.routeName,
          path: UserJournalEditPage.routePath,
          builder: (context, params) =>
              UserJournalEditPage(userJournalEntryRow: params.getParam('userJournalEntryRow', ParamType.SupabaseRow)),
        ),
        FFRoute(
          name: UserJourneysViewPage.routeName,
          path: UserJourneysViewPage.routePath,
          builder: (context, params) => const UserJourneysViewPage(),
        ),
        FFRoute(
          name: OnBoardingPage.routeName,
          path: OnBoardingPage.routePath,
          builder: (context, params) => const OnBoardingPage(),
        ),
        FFRoute(
          name: InAppNotificationsPage.routeName,
          path: InAppNotificationsPage.routePath,
          builder: (context, params) => const InAppNotificationsPage(),
        ),
        FFRoute(
          name: SetNotificationsPage.routeName,
          path: SetNotificationsPage.routePath,
          builder: (context, params) => const SetNotificationsPage(),
        ),
        FFRoute(
          name: MyExperiencesPage.routeName,
          path: MyExperiencesPage.routePath,
          builder: (context, params) => const MyExperiencesPage(),
        ),
        FFRoute(
          name: FavoritesPage.routeName,
          path: FavoritesPage.routePath,
          builder: (context, params) => const FavoritesPage(),
        ),
        // Support / Help Center routes
        FFRoute(
          name: SupportPage.routeName,
          path: SupportPage.routePath,
          builder: (context, params) => SupportPage(
            contextType: params.getParam('contextType', ParamType.String),
            contextId: params.getParam('contextId', ParamType.int),
            contextTitle: params.getParam('contextTitle', ParamType.String),
          ),
        ),
        FFRoute(
          name: NewRequestPage.routeName,
          path: NewRequestPage.routePath,
          builder: (context, params) => NewRequestPage(
            contextType: params.getParam('contextType', ParamType.String),
            contextId: params.getParam('contextId', ParamType.int),
            contextTitle: params.getParam('contextTitle', ParamType.String),
          ),
        ),
        FFRoute(
          name: RequestChatPage.routeName,
          path: RequestChatPage.routePath,
          builder: (context, params) => RequestChatPage(requestId: params.getParam('id', ParamType.int) ?? 0),
        ),
        FFRoute(
          name: GroupModerationPage.routeName,
          path: GroupModerationPage.routePath,
          builder: (context, params) => GroupModerationPage(
            groupId: params.getParam('groupId', ParamType.int),
            groupName: params.getParam('groupName', ParamType.String),
          ),
        ),
        FFRoute(
          name: MemberManagementPage.routeName,
          path: MemberManagementPage.routePath,
          builder: (context, params) => MemberManagementPage(
            groupId: params.getParam('groupId', ParamType.int),
            groupName: params.getParam('groupName', ParamType.String),
          ),
        ),
        FFRoute(
          name: CommunityGuidelinesPage.routeName,
          path: CommunityGuidelinesPage.routePath,
          builder: (context, params) => const CommunityGuidelinesPage(),
        ),
        FFRoute(
          name: CommunityGuidelinesEditPage.routeName,
          path: CommunityGuidelinesEditPage.routePath,
          builder: (context, params) => const CommunityGuidelinesEditPage(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
      observers: [routeObserver],
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls =>
      Map.fromEntries(entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)));
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect ? null : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) => !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) => appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap {
    final value = extra;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty || (state.allParams.length == 1 && state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) => asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map((param) async {
          final doc = await asyncParams[param.key]!(param.value).onError((_, __) => null);
          if (doc != null) {
            futureParamValues[param.key] = doc;
            return true;
          }
          return false;
        }),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(String paramName, ParamType type, {bool isList = false, StructBuilder<T>? structBuilder}) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(param, type, isList, structBuilder: structBuilder);
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/splash';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(future: ffParams.completeFutures(), builder: (context, _) => builder(context, ffParams))
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(context, animation, secondaryAnimation, child),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage && location != '/' && location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) =>
      Provider.value(value: RootPageContext(true, errorRoute), child: child);
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList =
        lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
