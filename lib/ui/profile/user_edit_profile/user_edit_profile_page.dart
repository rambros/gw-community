import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '/ui/core/themes/flutter_flow_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import 'view_model/user_edit_profile_view_model.dart';

class UserEditProfilePage extends StatefulWidget {
  const UserEditProfilePage({super.key});

  static String routeName = 'userEditProfile';
  static String routePath = '/userEditProfile';

  @override
  State<UserEditProfilePage> createState() => _UserEditProfilePageState();
}

class _UserEditProfilePageState extends State<UserEditProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserEditProfileViewModel>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserEditProfileViewModel>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 46.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryBackground,
            size: 25.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Your Profile',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryBackground,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
        actions: const [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: viewModel.isLoading
            ? Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SpinKitRipple(
                    color: FlutterFlowTheme.of(context).primary,
                    size: 50.0,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(color: FlutterFlowTheme.of(context).error),
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 32.0, 8.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                                  child: TextFormField(
                                    controller: viewModel.firstNameController,
                                    onChanged: viewModel.updateFirstName,
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
                                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
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
                                    onChanged: viewModel.updateLastName,
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
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                child: Text(
                                  'Hide my last name',
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
                              Switch(
                                value: viewModel.hideLastName,
                                onChanged: (newValue) async {
                                  viewModel.setHideLastName(newValue);
                                },
                                activeThumbColor: FlutterFlowTheme.of(context).primary,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                                  child: TextFormField(
                                    controller: viewModel.displayNameController,
                                    autofocus: false,
                                    readOnly: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Display Name',
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                                  child: TextFormField(
                                    controller: viewModel.bioController,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: ' Info  (Optional)',
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
                                      hintText: '(Optional) Info about you that you want to share',
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
                                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
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
                                    maxLines: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    context.pop();
                                  },
                                  text: 'Cancel',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                    iconPadding: const EdgeInsets.all(0.0),
                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                    textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).secondary,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    await viewModel.saveProfileCommand(context);
                                  },
                                  text: 'Save Changes',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                    iconPadding: const EdgeInsets.all(0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
