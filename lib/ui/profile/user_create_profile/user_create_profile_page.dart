import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
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
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
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
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryBackground,
                fontSize: 20.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondary,
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
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
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                    labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                        ),
                                    hintText: 'FirstName',
                                    hintStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.lexendDeca(
                                            fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).alternate,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
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
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondary,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                    labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                        ),
                                    hintText: 'Last Name',
                                    hintStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.lexendDeca(
                                            fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).alternate,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
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
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondary,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                      color: FlutterFlowTheme.of(context).secondary,
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
                                      color: FlutterFlowTheme.of(context).secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.5),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                  ),
                              elevation: 1.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
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
                    color: FlutterFlowTheme.of(context).primary,
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
