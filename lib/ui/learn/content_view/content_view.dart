import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_animations.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_pdf_viewer.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/learn/content_view/view_model/content_view_model.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class ContentView extends StatefulWidget {
  const ContentView({
    super.key,
    required this.contentId,
    required this.viewContentRow,
  });

  final int contentId;
  final ViewContentRow viewContentRow;

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView>
    with TickerProviderStateMixin {
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContentViewModel(
        contentId: widget.contentId,
        viewContentRow: widget.viewContentRow,
      ),
      child: Consumer<ContentViewModel>(
        builder: (context, viewModel, child) {
          final row = viewModel.viewContentRow ?? widget.viewContentRow;
          final modalMaxHeight = MediaQuery.sizeOf(context).height * 0.75;
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppTheme.of(context)
                  .primaryBackground
                  .withValues(alpha: 0.82),
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: GestureDetector(
                  onTap: () {}, // Prevents tap from propagating to parent
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 80.0, 16.0, 80.0),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 600.0,
                        maxHeight: modalMaxHeight,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primaryBackground,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12.0,
                            color: Color(0x1E000000),
                            offset: Offset(0.0, 5.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row with Favorite and Close buttons
                            Align(
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8.0, 16.0, 8.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Favorite button
                                    if (context
                                            .currentUserIdOrEmpty.isNotEmpty &&
                                        row.contentId != null)
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 8.0, 0.0),
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: AppTheme.of(context)
                                                .secondaryBackground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: FavoriteButton(
                                              contentType: FavoritesRepository
                                                  .typeRecording,
                                              contentId: row.contentId!,
                                              authUserId:
                                                  context.currentUserIdOrEmpty,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Close button
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: AppTheme.of(context).primary,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 24.0, 16.0, 12.0),
                                    child: Text(
                                      valueOrDefault<String>(
                                        row.title,
                                        context.l10n.untitled,
                                      ),
                                      style: AppTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context).primary,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyLarge
                                                .fontStyle,
                                          ),
                                    ),
                                  ),

                                  // Authors
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 8.0),
                                    child: Text(
                                      context.l10n.withAuthors(
                                        row.authorsNames.join(', '),
                                      ),
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexendDeca(
                                              fontWeight: FontWeight.normal,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context).primary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                  ),

                                  // Event
                                  if ((row.cottEventId != null) &&
                                      (row.cottEventId! > 0))
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 8.0),
                                      child: Text(
                                        context.l10n
                                            .atEvent(row.eventName ?? ''),
                                        style: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: FontWeight.normal,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                              color:
                                                  AppTheme.of(context).primary,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                      ),
                                    ),

                                  // Description
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 8.0),
                                    child: SelectionArea(
                                        child: Text(
                                      valueOrDefault<String>(
                                        row.description,
                                        '',
                                      ),
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexendDeca(
                                              fontWeight: FontWeight.normal,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context).primary,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    )),
                                  ),

                                  // Media Content
                                  // Audio
                                  if (viewModel.midiaType == 'audio')
                                    SizedBox(
                                      width: double.infinity,
                                      height: 320,
                                      child: AudioPlayerWidget(
                                        width: double.infinity,
                                        height: 320,
                                        audioUrl: row.audioUrl!,
                                        audioTitle: row.title!,
                                        audioArt: ' ',
                                        colorButton:
                                            AppTheme.of(context).primary,
                                      ),
                                    ),

                                  // PDF
                                  if ((viewModel.midiaType == 'pdf' ||
                                          viewModel.midiaType == 'text') &&
                                      (row.midiaFileUrl ?? '').isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 0.0),
                                      child: FlutterFlowPdfViewer(
                                        networkPath: row.midiaFileUrl!,
                                        height: 600.0,
                                        horizontalScroll: false,
                                      ),
                                    ),

                                  // Video
                                  if (viewModel.midiaType == 'video' &&
                                      row.midiaFileUrl != null)
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 0.0),
                                      child: FlutterFlowYoutubePlayer(
                                        url: row.midiaFileUrl!,
                                        autoPlay: false,
                                        looping: true,
                                        mute: false,
                                        showControls: true,
                                        showFullScreen: true,
                                        strictRelatedVideos: false,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['containerOnPageLoadAnimation']!),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
