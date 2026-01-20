import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/profile/user_profile_page/view_model/user_profile_view_model.dart';
import 'package:gw_community/ui/profile/user_profile_page/widgets/profile_menu_item_widget.dart';
import 'package:gw_community/ui/profile/widgets/confirm_profile_action_dialog.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  static String routeName = 'userProfilePage';
  static String routePath = '/userProfilePage';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileViewModel>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserProfileViewModel>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: AppTheme.of(context).headlineMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                ),
                color: Colors.white,
                fontSize: 20.0,
                letterSpacing: 0.0,
                fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
        actions: const [],
        centerTitle: true,
        elevation: 4.0,
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: SpinKitRipple(
            color: AppTheme.of(context).primary,
            size: 50.0,
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: AppTheme.of(context).bodyMedium,
        ),
      );
    }

    final userProfile = viewModel.userProfile;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Name and Email
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            userProfile?.displayName,
                            'Name',
                          ),
                          style: AppTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                                  fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                                fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                              ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              valueOrDefault<String>(
                                userProfile?.email,
                                'Email',
                              ),
                              textAlign: TextAlign.start,
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: AppTheme.of(context).primary,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                          ),
                        ),
                        // Display role using UserRole enum
                        Builder(
                          builder: (context) {
                            debugPrint('==== Profile Role Debug ====');
                            debugPrint('userProfile: ${userProfile != null}');
                            debugPrint('userRole: ${userProfile?.userRole}');
                            debugPrint('userRole length: ${userProfile?.userRole.length}');

                            final roles = userProfile?.userRole ?? [];
                            debugPrint('roles variable: $roles');

                            // SEMPRE MOSTRAR PARA DEBUG
                            debugPrint('ALWAYS SHOWING FOR DEBUG - roles length: ${roles.length}');
                            if (roles.isEmpty) {
                              debugPrint('⚠️ WARNING: roles is EMPTY!');
                            }

                            // Check if has admin or group manager role using enum
                            final hasAdminRole = roles.hasAdminOrGroupManager;
                            debugPrint('hasAdminOrGroupManager: $hasAdminRole');

                            // Get the role to display (prioritize admin, then group manager)
                            UserRole? roleToDisplay;
                            if (roles.hasAdmin) {
                              roleToDisplay = UserRole.admin;
                            } else if (roles.hasGroupManager) {
                              roleToDisplay = UserRole.groupManager;
                            }

                            debugPrint('roleToDisplay: "$roleToDisplay"');
                            debugPrint('==== End Debug ====');

                            // Show role badge only if user has admin or group manager role
                            if (!hasAdminRole || roleToDisplay == null) {
                              return const SizedBox.shrink();
                            }

                            return Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context).primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    roleToDisplay.displayName,
                                    textAlign: TextAlign.start,
                                    style: AppTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.lexendDeca(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          color: AppTheme.of(context).primary,
                                          fontSize: 11.0,
                                          letterSpacing: 1.0,
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                ProfileMenuItemWidget(
                  text: 'My Journal',
                  onTap: () async {
                    context.pushNamed(
                      UserJournalListPage.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                  child: ProfileMenuItemWidget(
                    text: 'My Journey',
                    onTap: () async {
                      context.pushNamed(
                        UserJourneysViewPage.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                  child: ProfileMenuItemWidget(
                    text: 'Favorites',
                    onTap: () async {
                      context.pushNamed(
                        FavoritesPage.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                  child: ProfileMenuItemWidget(
                    text: 'Ask a Question',
                    onTap: () async {
                      context.pushNamed(SupportPage.routeName);
                    },
                  ),
                ),
              ],
            ),

            // Account Settings Header
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 0.0, 12.0),
                  child: Text(
                    'Account Settings',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.bold,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: AppTheme.of(context).secondary,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ],
            ),

            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
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
                    text: 'Reset Journey',
                    onTap: () async {
                      await _handleResetJourney(context, viewModel);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                  child: ProfileMenuItemWidget(
                    text: 'Reset Onboarding',
                    onTap: () async {
                      await _handleResetOnboarding(context, viewModel);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
              child: FFButtonWidget(
                onPressed: () async {
                  await _handleLogout(context, viewModel);
                },
                text: 'Log Out',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 48.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: AppTheme.of(context).primary,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                          fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 3.0,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetJourney(BuildContext context, UserProfileViewModel viewModel) async {
    var confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return const WebViewAware(
              child: ConfirmProfileActionDialog(
                title: 'Reset your Good Wishes Journey',
                description: 'Resetting your journey will delete all progress made so far. '
                    'This action cannot be undone.',
                confirmLabel: 'Reset Journey',
                icon: Icons.restart_alt,
              ),
            );
          },
        ) ??
        false;

    if (confirmDialogResponse) {
      try {
        await viewModel.resetJourneyCommand();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Journey reset with success',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                ),
              ),
              duration: const Duration(milliseconds: 4000),
              backgroundColor: AppTheme.of(context).secondary,
            ),
          );

          GoRouter.of(context).prepareAuthEvent();
          // signOut is handled in ViewModel, but we need to clear redirect here
          GoRouter.of(context).clearRedirectLocation();

          context.goNamed(SplashPage.routeName);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error resetting journey: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleResetOnboarding(BuildContext context, UserProfileViewModel viewModel) async {
    final confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return const WebViewAware(
              child: ConfirmProfileActionDialog(
                title: 'Reset onboarding experience',
                description: 'We will clear your onboarding progress so you can go through the introduction again.',
                confirmLabel: 'Reset Onboarding',
                icon: Icons.flag_outlined,
              ),
            );
          },
        ) ??
        false;

    if (!confirmDialogResponse) {
      return;
    }

    try {
      await viewModel.resetOnboardingCommand();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Onboarding reset successfully.',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: AppTheme.of(context).secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error resetting onboarding: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, UserProfileViewModel viewModel) async {
    try {
      await viewModel.logoutCommand();

      if (context.mounted) {
        GoRouter.of(context).prepareAuthEvent();
        GoRouter.of(context).clearRedirectLocation();
        context.goNamed(SplashPage.routeName);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error logging out: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
