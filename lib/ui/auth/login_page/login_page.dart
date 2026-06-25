import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/auth/login_page/view_model/login_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/home/home_page/home_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String routeName = 'login';
  static String routePath = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _magicEmailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _magicEmailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _magicFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _magicEmailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _magicEmailFocusNode.dispose();
    super.dispose();
  }

  void _showAuthError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: TextStyle(color: AppTheme.of(context).primaryText),
        ),
        backgroundColor: AppTheme.of(context).secondary,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTheme.of(context).labelLarge.override(
            font: GoogleFonts.poppins(
              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
            ),
            color: AppTheme.of(context).primary,
            fontSize: 16.0,
            letterSpacing: 0.0,
          ),
      hintText: hint,
      hintStyle: AppTheme.of(context).bodySmall.override(
            font: GoogleFonts.lexendDeca(
              fontWeight: AppTheme.of(context).bodySmall.fontWeight,
              fontStyle: AppTheme.of(context).bodySmall.fontStyle,
            ),
            color: AppTheme.of(context).alternate,
            letterSpacing: 0.0,
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
    );
  }

  TextStyle _inputStyle(BuildContext context) {
    return AppTheme.of(context).bodyMedium.override(
          font: GoogleFonts.lexendDeca(
            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
          ),
          color: AppTheme.of(context).secondary,
          fontSize: 14.0,
          letterSpacing: 0.0,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: AppTheme.of(context).primaryBackground),
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/GoodWishes_RGB_Logo_Stacked_600.png',
                          width: 300.0,
                          height: 88.0,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: viewModel.isMagicLinkMode
                        ? _buildMagicLinkSection(context, viewModel)
                        : _buildPasswordSection(context, viewModel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Magic Link mode ───────────────────────────────────────────────────────

  Widget _buildMagicLinkSection(BuildContext context, LoginViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 36.0, 24.0, 0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Welcome,',
              style: AppTheme.of(context).displaySmall.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).displaySmall.fontWeight,
                      fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                    ),
                    color: AppTheme.of(context).secondary,
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 24.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter your email to receive a secure access link.',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
        if (viewModel.magicLinkSent)
          _buildMagicLinkSentCard(context, viewModel)
        else
          _buildMagicLinkForm(context, viewModel),
        const SizedBox(height: 24.0),
        _buildModeToggle(context, viewModel, toPassword: true),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildMagicLinkForm(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: _magicFormKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
            child: TextFormField(
              controller: _magicEmailController,
              focusNode: _magicEmailFocusNode,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(context, 'Email', hint: 'Your email'),
              style: _inputStyle(context),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 16.0, 4.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isMagicLinkLoading
                  ? null
                  : () async {
                      if (!_magicFormKey.currentState!.validate()) return;
                      final messenger = ScaffoldMessenger.of(context);
                      final theme = AppTheme.of(context);
                      final result = await viewModel.sendMagicLink(_magicEmailController.text);
                      if (!mounted) return;
                      if (result == SendMagicLinkResult.notRegistered) {
                        messenger.showSnackBar(SnackBar(
                          content: Text(
                            'Email not registered. Contact your administrator.',
                            style: TextStyle(color: theme.primaryText),
                          ),
                          backgroundColor: theme.secondary,
                        ));
                      } else if (result == SendMagicLinkResult.error) {
                        messenger.showSnackBar(SnackBar(
                          content: Text(
                            'Error sending link. Please try again.',
                            style: TextStyle(color: theme.primaryText),
                          ),
                          backgroundColor: theme.secondary,
                        ));
                      }
                    },
              text: 'Send Access Link',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50.0,
                padding: EdgeInsetsDirectional.zero,
                iconPadding: EdgeInsetsDirectional.zero,
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
                borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              showLoadingIndicator: viewModel.isMagicLinkLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicLinkSentCard(BuildContext context, LoginViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 0.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppTheme.of(context).primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.mark_email_read_outlined, size: 48, color: AppTheme.of(context).primary),
            const SizedBox(height: 12),
            Text(
              'Check your email!',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent an access link to ${_magicEmailController.text}. Tap it to sign in.',
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                viewModel.resetMagicLinkState();
              },
              child: Text(
                'Resend link',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Password mode ─────────────────────────────────────────────────────────

  Widget _buildPasswordSection(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 36.0, 24.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome,',
                style: AppTheme.of(context).displaySmall.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: AppTheme.of(context).displaySmall.fontWeight,
                        fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                      ),
                      color: AppTheme.of(context).secondary,
                      fontSize: 24.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Access your account below.',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
            child: TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(context, 'Email', hint: 'Your email'),
              style: _inputStyle(context),
              validator: (val) => (val == null || val.isEmpty) ? 'Field is required' : null,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              autofocus: false,
              obscureText: !viewModel.passwordVisibility,
              decoration: _inputDecoration(context, 'Password', hint: 'Your password').copyWith(
                suffixIcon: InkWell(
                  onTap: viewModel.togglePasswordVisibility,
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
              style: _inputStyle(context),
              validator: (val) => (val == null || val.isEmpty) ? 'Field is required' : null,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 24.0, 4.0, 0.0),
            child: FFButtonWidget(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final user = await viewModel.signIn(context, _emailController.text, _passwordController.text);
                    if (user != null && context.mounted) {
                      context.pushNamed(HomePage.routeName);
                    }
                  } catch (e) {
                    if (context.mounted) _showAuthError(e);
                  }
                }
              },
              text: 'Login',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50.0,
                padding: EdgeInsetsDirectional.zero,
                iconPadding: EdgeInsetsDirectional.zero,
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
                borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              showLoadingIndicator: viewModel.isEmailLoading,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 4.0, 8.0),
              child: GestureDetector(
                onTap: () => context.pushNamed('forgotPassword'),
                child: Text(
                  'Forgot password?',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.lexendDeca(),
                        color: AppTheme.of(context).primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _buildModeToggle(context, viewModel, toPassword: false),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  // ─── Shared toggle ──────────────────────────────────────────────────────────

  Widget _buildModeToggle(BuildContext context, LoginViewModel viewModel, {required bool toPassword}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Divider(color: AppTheme.of(context).alternate, endIndent: 12),
              GestureDetector(
                onTap: viewModel.toggleLoginMode,
                child: Text(
                  toPassword ? 'Sign in with password →' : '← Sign in without password',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.lexendDeca(),
                        color: AppTheme.of(context).primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
