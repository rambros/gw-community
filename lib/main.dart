import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:gw_community/config/audio/audio_service.dart';
import 'package:gw_community/config/firebase/firebase_config.dart';
import 'package:gw_community/data/services/push/push_notification_service.dart';
import 'package:provider/provider.dart';
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
import 'package:gw_community/ui/auth/forgot_password_page/view_model/forgot_password_view_model.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

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

  if (!kIsWeb) {
    await PushNotificationService.instance.initialize();
  }

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Tracks the last URI string we dispatched to avoid reprocessing the same
  // link on every app resume (iOS stores the latest link persistently).
  String? _lastHandledUriStr;

  // Timestamp of the last link delivered by uriLinkStream. Used to suppress
  // _checkLinkOnResume() on Android, where getInitialLink() returns the
  // first-ever link for the process (stale after warm starts) instead of
  // the latest one — unlike iOS which always returns the most recent link.
  DateTime? _lastStreamLinkAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // On iOS, application(_:open:url:options:) fires AFTER
      // applicationDidBecomeActive (which triggers `resumed`). We wait a
      // short time so the native AppDelegate has stored the URL via
      // AppLinks.shared.handleLink before we read it back via getInitialLink.
      Future.delayed(const Duration(milliseconds: 600), _checkLinkOnResume);
    }
  }

  /// Fallback for warm-start deep links when uriLinkStream doesn't fire.
  /// AppLinks.shared.handleLink (called in AppDelegate) always updates the
  /// stored initial-link, so getInitialLink returns the latest URL even for
  /// warm starts — as long as we call it after the 600 ms window above.
  Future<void> _checkLinkOnResume() async {
    if (!mounted) return;
    // On Android, getInitialLink() returns the link from when this process was
    // first created — it never updates for subsequent warm-start intents.
    // If the stream already delivered a link in the last 3 seconds, skip to
    // avoid reprocessing a stale link from a previous session.
    final lastStream = _lastStreamLinkAt;
    if (lastStream != null &&
        DateTime.now().difference(lastStream).inSeconds < 3) {
      return;
    }
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;
      final uriStr = uri.toString();
      if (uriStr == _lastHandledUriStr) return; // already handled
      debugPrint('🔗 [resume-check] found link: $uri');
      _lastHandledUriStr = uriStr;
      _handleDeepLink(uri);
    } catch (e) {
      debugPrint('🔗 [resume-check] error: $e');
    }
  }

  // ── Deep-link initialisation ───────────────────────────────────────────────

  Future<void> _initDeepLinks() async {
    // Track whether the stream already handled a link so getInitialLink()
    // does not override it with a stale cached URL (Android caches the very
    // first link the process ever saw, causing old used-tokens to fire again).
    bool handledViaStream = false;

    // Handle deep link when app is already running (warm start).
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        handledViaStream = true;
        _lastHandledUriStr = uri.toString();
        _lastStreamLinkAt = DateTime.now();
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
        _lastHandledUriStr = initialUri.toString();
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // Cold-start fallback: didChangeAppLifecycleState.resumed is NOT fired
    // on cold start (app starts already in resumed state — no transition).
    // iOS may also deliver the URL via application:open:url:options: AFTER
    // didFinishLaunchingWithOptions, meaning getInitialLink() above could
    // return null if it runs before that callback. Two retries cover the
    // race window. _checkLinkOnResume's _lastHandledUriStr guard prevents
    // double-processing if the URL is found on the first retry.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _checkLinkOnResume();
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _checkLinkOnResume();
    });
  }

  // ── Deep-link handling ─────────────────────────────────────────────────────

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('🔗 Deep link received: $uri');

    // Magic link callback — let supabase_flutter handle auth, but show errors
    if (uri.scheme == 'gw' && uri.host == 'login-callback') {
      final errorCode = uri.queryParameters['error_code'];
      if (errorCode != null) {
        _showMagicLinkError(errorCode);
      }
    }
  }

  void _showMagicLinkError(String errorCode) {
    final message = errorCode == 'otp_expired'
        ? 'The access link has expired. Please request a new one.'
        : 'Authentication failed. Please try again.';

    // Retry until the context is inside the router tree (handles cold-start)
    _showMagicLinkErrorWithRetry(message);
  }

  void _showMagicLinkErrorWithRetry(String message, [int attempt = 0]) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      if (attempt < 10) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showMagicLinkErrorWithRetry(message, attempt + 1);
        });
      }
      return;
    }

    try {
      ctx.go('/login');
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ));
    } catch (_) {
      if (attempt < 10) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showMagicLinkErrorWithRetry(message, attempt + 1);
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
