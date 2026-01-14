import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class JourneyAboutDialog extends StatelessWidget {
  const JourneyAboutDialog({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.8,
          constraints: const BoxConstraints(
            maxWidth: 600.0,
            maxHeight: 700.0,
          ),
          decoration: BoxDecoration(
            color: theme.alternate,
            borderRadius: BorderRadius.circular(0.0),
            border: Border.all(
              color: theme.secondary,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com título e botão fechar
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.secondary,
                              size: 28.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                'About $title',
                                style: theme.headlineMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: theme.headlineMedium.fontWeight,
                                    fontStyle: theme.headlineMedium.fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FlutterFlowIconButton(
                      borderColor: theme.secondary,
                      borderRadius: 30.0,
                      borderWidth: 2.0,
                      buttonSize: 44.0,
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.secondary,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 24.0,
                  thickness: 2.0,
                  color: theme.secondary,
                ),

                // Conteúdo markdown scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                      child: MarkdownBody(
                        data: description,
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            launchURL(href);
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.lexendDeca(
                            color: theme.primaryText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                          ),
                          strong: GoogleFonts.lexendDeca(
                            color: theme.primaryText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                          em: GoogleFonts.lexendDeca(
                            color: theme.primaryText,
                            fontSize: 14.0,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                          h1: GoogleFonts.lexendDeca(
                            color: theme.tertiary,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: GoogleFonts.lexendDeca(
                            color: theme.tertiary,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: GoogleFonts.lexendDeca(
                            color: theme.tertiary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                          a: GoogleFonts.lexendDeca(
                            color: theme.primary,
                            fontSize: 14.0,
                            decoration: TextDecoration.underline,
                          ),
                          listBullet: GoogleFonts.lexendDeca(
                            color: theme.primaryText,
                            fontSize: 14.0,
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
      ),
    );
  }
}
