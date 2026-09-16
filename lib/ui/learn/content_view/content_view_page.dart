import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_pdf_viewer.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/core/widgets/transcript_markdown.dart';
import 'package:gw_community/ui/learn/content_view/view_model/content_view_model.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class ContentViewPage extends StatefulWidget {
  const ContentViewPage({
    super.key,
    required this.contentId,
    this.previewRow,
  });

  final int contentId;
  final ViewContentRow? previewRow;

  static String routeName = 'contentViewPage';
  static String routePath = '/contentViewPage';

  @override
  State<ContentViewPage> createState() => _ContentViewPageState();
}

class _ContentViewPageState extends State<ContentViewPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContentViewModel(
        contentId: widget.contentId,
        viewContentRow: widget.previewRow,
      )..load(),
      child: Consumer<ContentViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.viewContentRow == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: AppTheme.of(context).primary),
              body: Center(child: SpinKitRipple(color: AppTheme.of(context).primary, size: 50)),
            );
          }

          if (viewModel.error != null || viewModel.viewContentRow == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: AppTheme.of(context).primary),
              body: Center(child: Text(viewModel.error ?? context.l10n.noContentFound)),
            );
          }

          final row = viewModel.viewContentRow!;
          final mediaType = viewModel.midiaType;

          return Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: AppTheme.of(context).primary,
              title: Text(
                valueOrDefault<String>(row.title, context.l10n.untitled),
                style: AppTheme.of(context).headlineMedium.override(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
              actions: [
                if (context.currentUserIdOrEmpty.isNotEmpty && row.contentId != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                    child: FavoriteButton(
                      contentType: FavoritesRepository.typeRecording,
                      contentId: row.contentId!,
                      authUserId: context.currentUserIdOrEmpty,
                      size: 24,
                      iconColor: Colors.white,
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.isMessageType)
                    Text(
                      context.l10n.messageFromAuthors(row.authorsNames.join(', ')),
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.of(context).secondary,
                          ),
                    )
                  else ...[
                    Text(
                      valueOrDefault<String>(row.title, context.l10n.untitled),
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.of(context).secondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.withAuthors(row.authorsNames.join(', ')),
                      style: AppTheme.of(context).bodyMedium.override(
                            fontSize: 12,
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    if ((row.cottEventId ?? 0) > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.atEvent(row.eventName ?? ''),
                        style: AppTheme.of(context).bodyMedium.override(
                              fontSize: 12,
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ],
                  ],
                  if ((row.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SelectionArea(
                      child: Text(
                        row.description!,
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                  ],
                  if (mediaType == 'audio' && (row.audioUrl ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 320,
                      child: AudioPlayerWidget(
                        width: double.infinity,
                        height: 320,
                        audioUrl: row.audioUrl!,
                        audioTitle: row.title ?? '',
                        audioArt: ' ',
                        colorButton: AppTheme.of(context).primary,
                      ),
                    ),
                  ],
                  if (mediaType == 'video' && (row.midiaFileUrl ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    FlutterFlowYoutubePlayer(
                      url: row.midiaFileUrl!,
                      autoPlay: false,
                      looping: true,
                      mute: false,
                      showControls: true,
                      showFullScreen: true,
                      strictRelatedVideos: false,
                    ),
                  ],
                  if (mediaType == 'text') ...[
                    const SizedBox(height: 16),
                    if ((row.text ?? '').isNotEmpty)
                      SelectionArea(
                        child: Text(
                          row.text!,
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexendDeca(),
                                color: AppTheme.of(context).secondary,
                              ),
                        ),
                      )
                    else if ((row.midiaFileUrl ?? '').isNotEmpty)
                      FlutterFlowPdfViewer(
                        networkPath: row.midiaFileUrl!,
                        height: 600,
                        horizontalScroll: false,
                      ),
                  ],
                  if (viewModel.hasTranscript) ...[
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text(
                        context.l10n.transcript,
                        style: AppTheme.of(context).labelLarge.override(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.of(context).secondary,
                            ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectionArea(
                            child: TranscriptMarkdown(
                              data: row.transcript!,
                              textColor: AppTheme.of(context).secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
