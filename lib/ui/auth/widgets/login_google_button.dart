import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_widgets.dart';

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
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: SizedBox(
        width: 230.0,
        height: 44.0,
        child: Stack(
          alignment: const AlignmentDirectional(-0.05, 0.0),
          children: [
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: FFButtonWidget(
                onPressed: isLoading ? null : onPressed,
                text: isLoading ? 'Signing in...' : 'Sign in with Google',
                icon: const Icon(
                  Icons.add,
                  size: 20.0,
                ),
                options: FFButtonOptions(
                  width: 230.0,
                  height: 44.0,
                  padding: EdgeInsets.zero,
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  iconColor: Colors.transparent,
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
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-0.83, 0.0),
              child: Container(
                width: 22.0,
                height: 22.0,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  'https://i0.wp.com/nanophorm.com/wp-content/uploads/2018/04/google-logo-icon-PNG-Transparent-Background.png?w=1000&ssl=1',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
