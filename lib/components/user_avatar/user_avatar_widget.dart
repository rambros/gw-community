import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_avatar_model.dart';
export 'user_avatar_model.dart';

class UserAvatarWidget extends StatefulWidget {
  const UserAvatarWidget({
    super.key,
    this.imageUrl,
    this.fullName,
  });

  final String? imageUrl;
  final String? fullName;

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  late UserAvatarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserAvatarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      shape: const CircleBorder(),
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          shape: BoxShape.circle,
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 0.0,
          ),
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: Stack(
            children: [
              if (widget.imageUrl != null && widget.imageUrl != '')
                Hero(
                  tag: widget.imageUrl!,
                  transitionOnUserGestures: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 500),
                      fadeOutDuration: const Duration(milliseconds: 500),
                      imageUrl: widget.imageUrl!,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              if (widget.imageUrl == null || widget.imageUrl == '')
                Align(
                  alignment: const AlignmentDirectional(0.1, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 0.0,
                      shape: const CircleBorder(),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 0.0,
                          ),
                        ),
                        child: Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            functions.getInitials(widget.fullName!)!,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 20.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
