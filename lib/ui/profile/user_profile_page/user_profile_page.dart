import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'view_model/user_profile_view_model.dart';

import 'widgets/profile_menu_item_widget.dart';
import '../widgets/confirm_reset_journey_dialog.dart';

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
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: Colors.white,
                fontSize: 20.0,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
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
            color: FlutterFlowTheme.of(context).primary,
            size: 50.0,
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    final userProfile = viewModel.userProfile;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
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
                          userProfile?.fullName,
                          'Name',
                        ),
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                            ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                          child: Text(
                            valueOrDefault<String>(
                              userProfile?.email,
                              'Email',
                            ),
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                          ),
                        ),
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
                      DemoAnimationsWidget.routeName,
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
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.bold,
                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondary,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetJourney(BuildContext context, UserProfileViewModel viewModel) async {
    var confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return const WebViewAware(
              child: ConfirmResetJourneyDialog(),
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
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: const Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).secondary,
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
}
