// lib/ui/auth/invite_accept_page/invite_accept_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'view_model/invite_accept_view_model.dart';

class InviteAcceptPage extends StatefulWidget {
  const InviteAcceptPage({super.key, required this.token});

  final String? token;

  static const String routeName = 'InviteAcceptPage';
  static const String routePath = '/invite';

  @override
  State<InviteAcceptPage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InviteAcceptPage> {
  late InviteAcceptViewModel _viewModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _viewModel = InviteAcceptViewModel(token: widget.token ?? '');
    // Initialize (validate token)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<InviteAcceptViewModel>(
        builder: (context, viewModel, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppTheme.of(context).primaryBackground,
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
                      _buildHeader(context),
                      _buildContent(context, viewModel),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/GoodWishes_RGB_Logo_Stacked_600.png',
            width: 300.0,
            height: 88.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 300.0,
              height: 88.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, InviteAcceptViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildStateContent(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, InviteAcceptViewModel viewModel) {
    if (viewModel.isValidatingToken) {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppTheme.of(context).primary),
            const SizedBox(height: 24),
            Text(
              'Verifying invitation...',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );
    }

    if (!viewModel.tokenValid) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.error_outline, size: 64, color: AppTheme.of(context).error),
            const SizedBox(height: 24),
            Text(
              'Invitation Invalid',
              style: AppTheme.of(context).displaySmall.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondary,
                    fontSize: 24.0,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.tokenError ?? 'This invitation link is invalid or has already been used.',
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 32),
            FFButtonWidget(
              onPressed: () => context.go('/login'),
              text: 'Go to Login',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50.0,
                color: AppTheme.of(context).primary,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                elevation: 3.0,
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ],
        ),
      );
    }

    return Form(
      key: viewModel.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                  child: Text(
                    'Welcome!',
                    style: AppTheme.of(context).displaySmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).secondary,
                          fontSize: 24.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Subtitle
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 16.0, 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          'Please create a password to access your account.',
                          textAlign: TextAlign.start,
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexendDeca(),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Password Field
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
            child: TextFormField(
              controller: viewModel.passwordController,
              focusNode: viewModel.passwordFocusNode,
              autofocus: true,
              obscureText: !viewModel.passwordVisibility,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
                      color: AppTheme.of(context).primary,
                      fontSize: 16.0,
                    ),
                hintText: 'Your password',
                hintStyle: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).alternate,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.of(context).alternate, width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.of(context).alternate, width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                suffixIcon: InkWell(
                  onTap: () => viewModel.togglePasswordVisibility(),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    viewModel.passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                ),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondary,
                    fontSize: 14.0,
                  ),
              cursorColor: AppTheme.of(context).primary,
              validator: viewModel.validatePassword,
            ),
          ),
          // Confirm Password Field
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
            child: TextFormField(
              controller: viewModel.confirmPasswordController,
              focusNode: viewModel.confirmPasswordFocusNode,
              obscureText: !viewModel.confirmPasswordVisibility,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
                      color: AppTheme.of(context).primary,
                      fontSize: 16.0,
                    ),
                hintText: 'Confirm your password',
                hintStyle: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).alternate,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.of(context).alternate, width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.of(context).alternate, width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                suffixIcon: InkWell(
                  onTap: () => viewModel.toggleConfirmPasswordVisibility(),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    viewModel.confirmPasswordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                ),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondary,
                    fontSize: 14.0,
                  ),
              cursorColor: AppTheme.of(context).primary,
              validator: viewModel.validateConfirmPassword,
            ),
          ),
          // Error Message
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 0.0),
              child: Text(
                viewModel.errorMessage!,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).error,
                    ),
              ),
            ),
          // Submit Button
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.submitPassword();
                      if (success && context.mounted) {
                        context.go('/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Account created successfully! Please log in.',
                              style: TextStyle(color: AppTheme.of(context).primaryText),
                            ),
                            backgroundColor: AppTheme.of(context).primary,
                          ),
                        );
                      }
                    },
              text: 'Create Account',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50.0,
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: AppTheme.of(context).primary,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                elevation: 3.0,
                borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
                borderRadius: BorderRadius.circular(40.0),
              ),
              showLoadingIndicator: viewModel.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
