import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_apple_model.dart';
export 'login_apple_model.dart';

class LoginAppleWidget extends StatefulWidget {
  const LoginAppleWidget({super.key});

  @override
  State<LoginAppleWidget> createState() => _LoginAppleWidgetState();
}

class _LoginAppleWidgetState extends State<LoginAppleWidget> {
  late LoginAppleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginAppleModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(
      onPressed: () {
        print('Button pressed ...');
      },
      text: 'Sign in with Apple',
      icon: const FaIcon(
        FontAwesomeIcons.apple,
        size: 20.0,
      ),
      options: FFButtonOptions(
        width: 230.0,
        height: 44.0,
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
