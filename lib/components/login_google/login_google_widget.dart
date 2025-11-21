import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_google_model.dart';
export 'login_google_model.dart';

class LoginGoogleWidget extends StatefulWidget {
  const LoginGoogleWidget({super.key});

  @override
  State<LoginGoogleWidget> createState() => _LoginGoogleWidgetState();
}

class _LoginGoogleWidgetState extends State<LoginGoogleWidget> {
  late LoginGoogleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginGoogleModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: SizedBox(
        width: 230.0,
        height: 44.0,
        child: Stack(
          alignment: const AlignmentDirectional(-0.050000000000000044, 0.0),
          children: [
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  GoRouter.of(context).prepareAuthEvent();
                  final user = await authManager.signInWithGoogle(context);
                  if (user == null) {
                    return;
                  }

                  context.goNamedAuth(HomePage.routeName, context.mounted);
                },
                text: 'Sign in with Google',
                icon: const Icon(
                  Icons.add,
                  size: 20.0,
                ),
                options: FFButtonOptions(
                  width: 230.0,
                  height: 44.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
