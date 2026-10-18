import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/experience_add_page/experience_add_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_pdf_viewer.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:gw_community/ui/core/ui/reading_text_size.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/core/widgets/transcript_markdown.dart';
import 'package:gw_community/ui/learn/content_view/view_model/content_view_model.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class ContentViewPage extends StatefulWidget {
  const ContentViewPage({
    super.key,
    required this.contentId,
    this.previewRow,
    this.librarySection,
  });

  final int contentId;
  final ViewContentRow? previewRow;
  final LibraryContentSection? librarySection;

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
        librarySection: widget.librarySection,
      )..load(),
      child: Consumer<ContentViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.viewContentRow == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: AppTheme.of(context).primary),
              body: Center(
                  child: SpinKitRipple(
                      color: AppTheme.of(context).primary, size: 50)),
            );
          }

          if (viewModel.error != null || viewModel.viewContentRow == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: AppTheme.of(context).primary),
              body: Center(
                  child: Text(viewModel.error ?? context.l10n.noContentFound)),
            );
          }

          final row = viewModel.viewContentRow!;
          final mediaType = viewModel.midiaType;
          final letter = (row.text ?? '').trim();

          Widget page({double? readingFontSize, Widget? readingControls}) {
            return Scaffold(
              backgroundColor: AppTheme.of(context).primaryBackground,
              appBar: AppBar(
                backgroundColor: AppTheme.of(context).primary,
                title: Text(
                  _headerTitle(context, viewModel, row),
                  style: AppTheme.of(context)
                      .headlineMedium
                      .override(color: Colors.white, fontSize: 18),
                ),
                centerTitle: true,
                actions: [
                  if (context.currentUserIdOrEmpty.isNotEmpty &&
                      row.contentId != null)
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
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
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (readingControls != null) readingControls,
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.isMessageType)
                            Text(
                              context.l10n.messageFromAuthors(
                                  row.authorsNames.join(', ')),
                              style: AppTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.of(context).secondary,
                                  ),
                            )
                          else ...[
                            Text(
                              valueOrDefault<String>(
                                  row.title, context.l10n.untitled),
                              style: AppTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.of(context).secondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n
                                  .withAuthors(row.authorsNames.join(', ')),
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
                          if ((row.description ?? '').isNotEmpty &&
                              !(mediaType == 'text' && letter.isNotEmpty)) ...[
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
                          if (mediaType == 'audio' &&
                              (row.audioUrl ?? '').isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _ContentAudioPlayer(
                              audioUrl: row.audioUrl!,
                              audioTitle: row.title ?? '',
                              offerShare: viewModel.librarySection ==
                                  LibraryContentSection.meditations,
                            ),
                          ],
                          if (mediaType == 'video' &&
                              (row.midiaFileUrl ?? '').isNotEmpty) ...[
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
                          if (mediaType == 'pdf' &&
                              (row.midiaFileUrl ?? '').isNotEmpty) ...[
                            const SizedBox(height: 16),
                            FlutterFlowPdfViewer(
                              networkPath: row.midiaFileUrl!,
                              height: 600,
                            ),
                          ],
                          if (mediaType == 'text') ...[
                            const SizedBox(height: 16),
                            if (letter.isNotEmpty)
                              SelectionArea(
                                child: Text(
                                  letter,
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexendDeca(),
                                        color: AppTheme.of(context).secondary,
                                        fontSize: readingFontSize,
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
                  ),
                ],
              ),
            );
          }

          if (mediaType == 'text' && letter.isNotEmpty) {
            return ReadingTextSize(
              barColor: AppTheme.of(context).primaryBackground,
              builder: (context, fontSize, controls) => page(
                readingFontSize: fontSize,
                readingControls: controls,
              ),
            );
          }
          return page();
        },
      ),
    );
  }

  String _headerTitle(
    BuildContext context,
    ContentViewModel viewModel,
    ViewContentRow row,
  ) {
    return switch (viewModel.librarySection) {
      LibraryContentSection.wordsOfWisdom => context.l10n.wordsOfWisdom,
      LibraryContentSection.dadiJanki => context.l10n.portalDadiJanki,
      LibraryContentSection.meditations => context.l10n.libraryHeaderMeditation,
      LibraryContentSection.dialoguesRetreats =>
        context.l10n.portalDialoguesRetreats,
      LibraryContentSection.heartToHeart =>
        context.l10n.libraryHeaderHeartToHeart,
      null => valueOrDefault<String>(row.title, context.l10n.untitled),
    };
  }
}

class _ContentAudioPlayer extends StatefulWidget {
  const _ContentAudioPlayer({
    required this.audioUrl,
    required this.audioTitle,
    required this.offerShare,
  });

  final String audioUrl;
  final String audioTitle;
  final bool offerShare;

  @override
  State<_ContentAudioPlayer> createState() => _ContentAudioPlayerState();
}

class _ContentAudioPlayerState extends State<_ContentAudioPlayer> {
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: AudioPlayerWidget(
            width: double.infinity,
            height: 320,
            audioUrl: widget.audioUrl,
            audioTitle: widget.audioTitle,
            audioArt: ' ',
            colorButton: AppTheme.of(context).primary,
            onCompleted: widget.offerShare
                ? () {
                    if (!_finished && mounted) {
                      setState(() => _finished = true);
                    }
                  }
                : null,
          ),
        ),
        if (_finished) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.of(context).primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                context.pushNamed(
                  ExperienceAddPage.routeName,
                  queryParameters: {
                    'chooseGroups': serializeParam(true, ParamType.bool),
                  }.withoutNulls,
                );
              },
              child: Text(
                context.l10n.likedShareExperience,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
