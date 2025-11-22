import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/utils/flutter_flow_util.dart';
import 'view_model/login_view_model.dart';
import '/ui/home/home_page/home_page.dart';
import '/ui/auth/widgets/login_google_button.dart';

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
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(LoginViewModel viewModel) async {
    try {
      final user = await viewModel.signInWithGoogle(context);
      if (user != null && mounted) {
        context.pushNamed(HomePage.routeName);
      }
    } catch (e) {
      if (!mounted) return;
      _showAuthError(e);
    }
  }

  void _showAuthError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
          ),
        ),
        backgroundColor: AppTheme.of(context).secondary,
      ),
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
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
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
                              ],
                            ),
                          ),
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
                                      Text(
                                        'Access your account below ',
                                        textAlign: TextAlign.start,
                                        style: AppTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                            child: TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: AppTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Your email',
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
                            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              autofocus: false,
                              obscureText: !viewModel.passwordVisibility,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: AppTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Your password',
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
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final user = await viewModel.signIn(
                                      context,
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                    if (user != null && context.mounted) {
                                      context.pushNamed(HomePage.routeName);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      _showAuthError(e);
                                    }
                                  }
                                }
                              },
                              text: 'Login',
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
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                            child: LoginGoogleButton(
                              onPressed: () => _handleGoogleSignIn(viewModel),
                              isLoading: viewModel.isLoading,
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
