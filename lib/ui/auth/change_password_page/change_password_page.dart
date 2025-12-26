import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/auth/change_password_page/view_model/change_password_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  static String routeName = 'changePassword';
  static String routePath = '/changePassword';

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangePasswordViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primary,
            automaticallyImplyLeading: false,
            leading: InkWell(
              onTap: () async {
                context.pop();
              },
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24.0,
              ),
            ),
            title: Text(
              'Change Password',
              style: AppTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                      fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                  ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 4.0,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
            ),
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Enter your new password below.',
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: AppTheme.of(context).secondaryText,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              autofocus: false,
                              obscureText: !viewModel.passwordVisibility,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                labelStyle: AppTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Enter new password',
                                hintStyle: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                        fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                      ),
                                      color: AppTheme.of(context).alternate,
                                      letterSpacing: 0.0,
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
                                suffixIcon: InkWell(
                                  onTap: () => viewModel.togglePasswordVisibility(),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    viewModel.passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppTheme.of(context).secondaryText,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: AppTheme.of(context).secondary,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Field is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              autofocus: false,
                              obscureText: !viewModel.confirmPasswordVisibility,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: AppTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Confirm new password',
                                hintStyle: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                                        fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                      ),
                                      color: AppTheme.of(context).alternate,
                                      letterSpacing: 0.0,
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
                                suffixIcon: InkWell(
                                  onTap: () => viewModel.toggleConfirmPasswordVisibility(),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    viewModel.confirmPasswordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppTheme.of(context).secondaryText,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: AppTheme.of(context).secondary,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Field is required';
                                }
                                if (val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await viewModel.updatePassword(
                                      _passwordController.text,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password updated successfully',
                                            style: TextStyle(
                                              color: AppTheme.of(context).primaryText,
                                            ),
                                          ),
                                          backgroundColor: AppTheme.of(context).secondary,
                                        ),
                                      );
                                      context.pop();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString(),
                                            style: TextStyle(
                                              color: AppTheme.of(context).primaryText,
                                            ),
                                          ),
                                          backgroundColor: AppTheme.of(context).secondary,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              text: 'Update Password',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                color: AppTheme.of(context).primary,
                                textStyle: AppTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                                        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                                      ),
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                elevation: 3.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              showLoadingIndicator: viewModel.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
