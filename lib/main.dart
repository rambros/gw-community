import '/config/audio/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '/data/services/supabase/supabase.dart';
import 'config/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'index.dart';
import '/domain/models/app_auth_user.dart';
import '/utils/context_extensions.dart';

// Repositories
import '/data/repositories/auth_repository.dart';
import '/data/repositories/auth_repository_impl.dart';
import '/data/services/auth/auth_service.dart';
import '/data/services/auth/supabase_auth_service.dart';
import '/data/repositories/event_repository.dart';
import '/data/repositories/community_repository.dart';
import '/data/repositories/notification_repository.dart';
import '/data/repositories/group_repository.dart';
import '/data/repositories/sharing_repository.dart';
import '/data/repositories/user_profile_repository.dart';
import '/data/repositories/home_repository.dart';
import '/data/repositories/learn_repository.dart';
import '/data/repositories/unsplash_repository.dart';
import '/data/repositories/journeys_repository.dart';
import '/data/repositories/step_activities_repository.dart';
import '/data/repositories/journal_repository.dart';

// ViewModels
import '/ui/auth/login_page/view_model/login_view_model.dart';
import '/ui/auth/create_account_page/view_model/create_account_view_model.dart';
import '/ui/auth/forgot_password_page/view_model/forgot_password_view_model.dart';
import '/ui/auth/change_password_page/view_model/change_password_view_model.dart';
import '/ui/auth/on_boarding_page/view_model/on_boarding_view_model.dart';
import 'ui/community/sharing_view_page/view_model/sharing_view_view_model.dart';
import 'ui/profile/user_profile_page/view_model/user_profile_view_model.dart';
import '/ui/profile/user_edit_profile/view_model/user_edit_profile_view_model.dart';
import '/ui/profile/user_create_profile/view_model/user_create_profile_view_model.dart';
import '/ui/profile/user_journal_list/view_model/user_journal_list_view_model.dart';
import '/ui/profile/user_journal_view/view_model/user_journal_view_model.dart';
import '/ui/profile/user_journal_edit/view_model/user_journal_edit_view_model.dart';
import '/ui/profile/user_journal_options/view_model/user_journal_options_view_model.dart';
import '/ui/profile/user_journeys_view/view_model/user_journeys_view_model.dart';
import '/ui/home/home_page/view_model/home_view_model.dart';
import '/ui/learn/learn_list_page/view_model/learn_list_view_model.dart';
import '/ui/onboarding/splash_page/view_model/splash_view_model.dart';
import '/ui/utility/unsplash_page/view_model/unsplash_view_model.dart';
import '/ui/journey/journeys_list_page/view_model/journeys_list_view_model.dart';

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
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            authService: context.read<AuthService>(),
          ),
        ),
        Provider(create: (_) => SharingRepository()),
        Provider(create: (_) => EventRepository()),
        Provider(create: (_) => CommunityRepository()),
        Provider(create: (_) => NotificationRepository()),
        Provider(create: (_) => GroupRepository()),
        Provider(create: (_) => UserProfileRepository()),
        Provider(create: (_) => HomeRepository()),
        Provider(create: (_) => LearnRepository()),
        Provider(create: (_) => UnsplashRepository()),
        Provider(create: (_) => JourneysRepository()),
        Provider(create: (_) => StepActivitiesRepository()),
        Provider(create: (_) => JournalRepository()),

        // ========== VIEW MODELS ==========
        ChangeNotifierProvider(create: (_) => LearnListViewModel()),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CreateAccountViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ForgotPasswordViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChangePasswordViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => OnBoardingViewModel(
            appState: context.read<FFAppState>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SharingViewViewModel(
            repository: context.read<SharingRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
            appState: context.read<FFAppState>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProfileViewModel(
            repository: context.read<UserProfileRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserEditProfileViewModel(
            repository: context.read<UserProfileRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserCreateProfileViewModel(
            repository: context.read<UserProfileRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalListViewModel(
            repository: context.read<UserProfileRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalViewModel(
            repository: context.read<UserProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalEditViewModel(
            repository: context.read<UserProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJournalOptionsViewModel(
            repository: context.read<UserProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserJourneysViewModel(
            repository: context.read<UserProfileRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            repository: context.read<HomeRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SplashViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => UnsplashViewModel(
            repository: context.read<UnsplashRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => JourneysListViewModel(
            repository: context.read<JourneysRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) => context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch = routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList =
        lastMatch is ImperativeRouteMatch ? lastMatch.matches : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() => _router.routerDelegate.currentConfiguration.matches.map((e) => getRoute(e)).toList();
  late Stream<AppAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    final authRepository = context.read<AuthRepository>();
    userStream = authRepository.authUserChanges
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    authRepository.jwtTokenChanges.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
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
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  const NavBarPage({
    super.key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  });

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  NavBarPageState createState() => NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'homePage';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'homePage': const HomePage(),
      'learnListPage': const LearnListPage(),
      'journeyPage': const JourneyPage(),
      'communityPage': const CommunityPage(),
      'userProfilePage': const UserProfilePage(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: Colors.white,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: const Color(0xFF95A1AC),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 28.0,
            ),
            label: 'Home',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.library_music,
              size: 24.0,
            ),
            label: 'Library',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FFIcons.kiconLogo,
              size: 24.0,
            ),
            activeIcon: Icon(
              FFIcons.kiconLogo,
              size: 24.0,
            ),
            label: 'Journey',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.public,
              size: 28.0,
            ),
            activeIcon: Icon(
              Icons.public,
              size: 28.0,
            ),
            label: 'Community',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
              size: 28.0,
            ),
            activeIcon: Icon(
              Icons.account_circle,
              size: 28.0,
            ),
            label: 'Profile',
            tooltip: '',
          )
        ],
      ),
    );
  }
}
