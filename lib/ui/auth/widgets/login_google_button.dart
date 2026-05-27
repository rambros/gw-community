import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';

/// UI-only Google login button that delegates behavior to the caller.
class LoginGoogleButton extends StatelessWidget {
  const LoginGoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(
      onPressed: isLoading ? null : onPressed,
      text: isLoading ? 'Signing in...' : 'Sign in with Google',
      icon: const FaIcon(
        FontAwesomeIcons.google,
        size: 20.0,
        color: Color(0xFFDB4437), // Google brand red color
      ),
      options: FFButtonOptions(
        width: 230.0,
        height: 44.0,
        padding: EdgeInsets.zero,
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 1.0),
        color: Colors.white,
        textStyle: GoogleFonts.roboto(
          color: const Color(0xFF606060),
          fontSize: 17.0,
        ),
        elevation: 4.0,
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 0.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}

