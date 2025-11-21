import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_widgets.dart';

/// UI-only Apple login button that delegates the tap action to the caller.
class LoginAppleButton extends StatelessWidget {
  const LoginAppleButton({
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
      text: isLoading ? 'Signing in...' : 'Sign in with Apple',
      icon: const FaIcon(
        FontAwesomeIcons.apple,
        size: 20.0,
      ),
      options: FFButtonOptions(
        width: 230.0,
        height: 44.0,
        padding: EdgeInsets.zero,
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 1.0),
        color: Colors.white,
        textStyle: GoogleFonts.roboto(
          color: Colors.black,
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
