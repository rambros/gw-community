import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/learn/content_view/content_view.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.contentRow,
  });

  final ViewContentRow contentRow;

  Future<void> _openContent(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      context: context,
      builder: (context) {
        return WebViewAware(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: ContentView(
              contentId: contentRow.contentId!,
              viewContentRow: contentRow,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openContent(context),
        child: Container(
          width: double.infinity,
          height: 110.0,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 8.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 2.0),
                spreadRadius: 1.0,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.of(context).primaryBackground,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                    child: AutoSizeText(
                                      valueOrDefault<String>(
                                        contentRow.title,
                                        'Title',
                                      ),
                                      textAlign: TextAlign.start,
                                      minFontSize: 12.0,
                                      style: AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.lexendDeca(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            color: AppTheme.of(context).secondary,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              (List<String> listAuthors) {
                                return listAuthors.join(', ');
                              }(contentRow.authorsNames.toList()),
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: AppTheme.of(context).secondary,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                            Flexible(
                              child: Align(
                                alignment: const AlignmentDirectional(-1.0, -1.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                        child: SelectionArea(
                                            child: Text(
                                          valueOrDefault<String>(
                                            contentRow.description,
                                            'description',
                                          ).maybeHandleOverflow(
                                            maxChars: 115,
                                            replacement: '…',
                                          ),
                                          textAlign: TextAlign.start,
                                          maxLines: 2,
                                          style: AppTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.lexendDeca(
                                                  fontWeight: FontWeight.w300,
                                                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: AppTheme.of(context).secondary,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w300,
                                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                        child: Builder(
                          builder: (context) {
                            if (contentRow.midiaType == 'audio') {
                              return Icon(
                                Icons.audiotrack_sharp,
                                color: AppTheme.of(context).primary,
                                size: 32.0,
                              );
                            } else if (contentRow.midiaType == 'text') {
                              return Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.text_snippet,
                                  color: AppTheme.of(context).primary,
                                  size: 32.0,
                                ),
                              );
                            } else if (contentRow.midiaType == 'video') {
                              return Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.ondemand_video,
                                  color: AppTheme.of(context).primary,
                                  size: 34.0,
                                ),
                              );
                            } else {
                              return Container(
                                width: 4.0,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context).secondaryBackground,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
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
