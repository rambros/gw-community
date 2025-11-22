import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import 'view_model/user_create_profile_view_model.dart';

class UserCreateProfilePage extends StatefulWidget {
  const UserCreateProfilePage({super.key});

  static String routeName = 'userCreateProfile';
  static String routePath = '/userCreateProfile';

  @override
  State<UserCreateProfilePage> createState() => _UserCreateProfilePageState();
}

class _UserCreateProfilePageState extends State<UserCreateProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserCreateProfileViewModel>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Sign Up',
          textAlign: TextAlign.center,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FontWeight.w500,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
                color: AppTheme.of(context).primaryBackground,
                fontSize: 20.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
              ),
        ),
        actions: const [],
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                        child: Image.asset(
                          'assets/images/GoodWishes_RGB_Logo_Stacked_600.png',
                          width: 330.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Text(
                        'What\'s your name?',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                                fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                              ),
                              color: AppTheme.of(context).secondary,
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                              fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'We are creating a community of real people and prefer real names. Please, enter your first and last names.',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: AppTheme.of(context).primary,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                                child: TextFormField(
                                  controller: viewModel.firstNameController,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    labelStyle: AppTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                            fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                          ),
                                          color: AppTheme.of(context).primary,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                          fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                        ),
                                    hintText: 'FirstName',
                                    hintStyle: AppTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.lexendDeca(
                                            fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                            fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                          ),
                                          color: AppTheme.of(context).alternate,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                          fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                  ),
                                  style: AppTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: AppTheme.of(context).secondary,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                                child: TextFormField(
                                  controller: viewModel.lastNameController,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    labelStyle: AppTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                            fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                          ),
                                          color: AppTheme.of(context).primary,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                          fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                        ),
                                    hintText: 'Last Name',
                                    hintStyle: AppTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.lexendDeca(
                                            fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                            fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                          ),
                                          color: AppTheme.of(context).alternate,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                          fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                  ),
                                  style: AppTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: AppTheme.of(context).secondary,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 0.0),
                                child: Text(
                                  'You can hide your Last Name in your Profile if you like.',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: AppTheme.of(context).primary,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'By creating an account, you are agreeing to our ',
                                    style: TextStyle(),
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions ',
                                    style: TextStyle(
                                      color: AppTheme.of(context).secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'and  ',
                                    style: TextStyle(),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy.',
                                    style: TextStyle(
                                      color: AppTheme.of(context).secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 40.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              await viewModel.completeSetupCommand(context);
                            },
                            text: 'Complete Setup',
                            options: FFButtonOptions(
                              width: 230.0,
                              height: 50.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: AppTheme.of(context).primary,
                              textStyle: AppTheme.of(context).labelLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                    ),
                                    color: AppTheme.of(context).primary.withValues(alpha: 0.5),
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                    fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                  ),
                              elevation: 1.0,
                              borderSide: BorderSide(
                                color: AppTheme.of(context).secondaryBackground,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (viewModel.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: SpinKitRipple(
                    color: AppTheme.of(context).primary,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
