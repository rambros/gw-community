import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:gw_community/config/audio/audio_service.dart';
import 'package:gw_community/config/firebase/firebase_config.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/repositories/auth_repository_impl.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/data/repositories/journal_repository.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/repositories/step_activities_repository.dart';
import 'package:gw_community/data/repositories/unsplash_repository.dart';
import 'package:gw_community/data/repositories/user_profile_repository.dart';
import 'package:gw_community/data/services/auth/auth_service.dart';
import 'package:gw_community/data/services/auth/supabase_auth_service.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/auth/change_password_page/view_model/change_password_view_model.dart';
import 'package:gw_community/ui/auth/create_account_page/view_model/create_account_view_model.dart';
import 'package:gw_community/ui/auth/forgot_password_page/view_model/forgot_password_view_model.dart';
import 'package:gw_community/ui/auth/invite_accept_page/pending_invite.dart';
import 'package:gw_community/ui/auth/login_page/view_model/login_view_model.dart';
import 'package:gw_community/ui/auth/on_boarding_page/view_model/on_boarding_view_model.dart';
import 'package:gw_community/ui/community/experience_view_page/view_model/experience_view_view_model.dart';
import 'package:gw_community/ui/core/app/view_model/app_view_model.dart';
import 'package:gw_community/ui/home/home_page/view_model/home_view_model.dart';
import 'package:gw_community/ui/journey/journeys_list_page/view_model/journeys_list_view_model.dart';
import 'package:gw_community/ui/learn/learn_list_page/view_model/learn_list_view_model.dart';
import 'package:gw_community/ui/onboarding/splash_page/view_model/splash_view_model.dart';
import 'package:gw_community/ui/profile/user_create_profile/view_model/user_create_profile_view_model.dart';
import 'package:gw_community/ui/profile/user_edit_profile/view_model/user_edit_profile_view_model.dart';
import 'package:gw_community/ui/profile/user_journal_edit/view_model/user_journal_edit_view_model.dart';
import 'package:gw_community/ui/profile/user_journal_list/view_model/user_journal_list_view_model.dart';
import 'package:gw_community/ui/profile/user_journal_options/view_model/user_journal_options_view_model.dart';
import 'package:gw_community/ui/profile/user_journal_view/view_model/user_journal_view_model.dart';
import 'package:gw_community/ui/profile/user_journeys_view/view_model/user_journeys_view_model.dart';
import 'package:gw_community/ui/profile/user_profile_page/view_model/user_profile_view_model.dart';
import 'package:gw_community/ui/utility/unsplash_page/view_model/unsplash_view_model.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:gw_community/utils/internationalization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  await SupaFlow.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  // Start final custom actions code
  await initAudioService();
  // End final custom actions code

  runApp(
    MultiProvider(
      providers: [
        // App State
        ChangeNotifierProvider(create: (context) => appState),

        // ========== REPOSITORIES ==========
        Provider<AuthService>(create: (_) => SupabaseAuthService()),
        Provider<AuthRepository>(create: (context) => AuthRepositoryImpl(authService: context.read<AuthService>())),
        Provider(create: (_) => ExperienceRepository()),
        Provider(create: (_) => EventRepository()),
        Provider(create: (_) => CommunityRepository()),
        Provider(create: (_) => AnnouncementRepository()),
        Provider(create: (_) => GroupRepository()),
        Provider(create: (_) => UserProfileRepository()),
        Provider(create: (_) => HomeRepository()),
        Provider(create: (_) => LearnRepository()),
        Provider(create: (_) => UnsplashRepository()),
        Provider(create: (_) => JourneysRepository()),
        Provider(create: (_) => StepActivitiesRepository()),
        Provider(create: (_) => JournalRepository()),
        Provider(create: (_) => FavoritesRepository()),

        ChangeNotifierProvider(create: (context) => AppViewModel(authRepository: context.read<AuthRepository>())),

        // ========== VIEW MODELS ==========
        ChangeNotifierProvider(create: (_) => LearnListViewModel()),
        ChangeNotifierProvider(create: (context) => LoginViewModel(authRepository: context.read<AuthRepository>())),
        ChangeNotifierProvider(
          create: (context) => CreateAccountViewModel(authRepository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ForgotPasswordViewModel(authRepository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ChangePasswordViewModel(authRepository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(create: (context) => OnBoardingViewModel(appState: context.read<FFAppState>())),
        ChangeNotifierProvider(
          create: (context) => ExperienceViewViewModel(
            repository: context.read<ExperienceRepository>(),
            appState: context.read<FFAppState>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProfileViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserEditProfileViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserCreateProfileViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalListViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalEditViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalOptionsViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJourneysViewModel(repository: context.read<UserProfileRepository>()),
        ),
        ChangeNotifierProvider(create: (context) => HomeViewModel(repository: context.read<HomeRepository>())),
        ChangeNotifierProvider(create: (context) => SplashViewModel()),
        ChangeNotifierProvider(create: (context) => UnsplashViewModel(repository: context.read<UnsplashRepository>())),
        ChangeNotifierProvider(
          create: (context) => JourneysListViewModel(repository: context.read<JourneysRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Track whether the stream already handled a link so getInitialLink()
    // does not override it with a stale cached URL (Android caches the very
    // first link the process ever saw, causing old used-tokens to fire again).
    bool handledViaStream = false;

    // Handle deep link when app is already running (warm start).
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        handledViaStream = true;
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );

    // Handle deep link that cold-started the app — only if the stream
    // hasn't already delivered a (more current) link.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && !handledViaStream) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('🔗 Deep link received: $uri');
    if (uri.scheme == 'gw' && uri.host == 'invite') {
      final token = uri.queryParameters['token'];
      debugPrint('🔗 Token: $token');
      if (token != null && token.isNotEmpty) {
        // On Android, getInitialLink() caches the very first deep link the process
        // ever received and returns it again on hot restart — even if that token is
        // already used/expired.  Persist the last-navigated token so we can skip it
        // on subsequent starts when no new link has actually been tapped.
        final prefs = await SharedPreferences.getInstance();
        final lastToken = prefs.getString('_gw_last_invite_token');
        if (token == lastToken) {
          debugPrint('🔗 Skipping stale cached invite token: $token');
          return;
        }
        await prefs.setString('_gw_last_invite_token', token);
        // Store as fallback: if navigation fails on first attempt, LoginPage picks this up.
        PendingInvite.token = token;
        _navigateToInvite('/invite?token=$token');
      }
    }
  }

  // Navigates to the invite page using the GoRouter's navigator key.
  // Retries if the context is not yet ready (e.g. cold start).
  void _navigateToInvite(String targetUrl, [int attempt = 0]) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null) {
      debugPrint('🔗 Navigating to: $targetUrl (attempt $attempt)');
      ctx.go(targetUrl);
      // Navigation succeeded — the token is now in the URL, so clear the
      // PendingInvite fallback.  Leaving it set would cause LoginPage.initState()
      // to redirect back to /invite if the token turns out to be invalid, creating
      // an infinite loop between "Invitation Invalid" and the login screen.
      PendingInvite.token = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppStateNotifier.instance.stopShowingSplashImage();
      });
    } else if (attempt < 5) {
      Future.delayed(Duration(milliseconds: 100 * (attempt + 1)), () {
        _navigateToInvite(targetUrl, attempt + 1);
      });
    } else {
      debugPrint('🔗 Failed to navigate to $targetUrl after $attempt attempts');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appViewModel = context.watch<AppViewModel>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'GW-Community',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: appViewModel.locale,
      supportedLocales: const [Locale('en')],
      theme: ThemeData(brightness: Brightness.light, useMaterial3: false),
      themeMode: appViewModel.themeMode,
      routerConfig: appViewModel.router,
    );
  }
}
