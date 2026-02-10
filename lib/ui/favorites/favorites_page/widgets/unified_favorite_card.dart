import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/favorites/unified_favorite_item.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/journey/step_audio_player_page/step_audio_player_page.dart';
import 'package:gw_community/ui/journey/step_text_view_page/step_text_view_page.dart';
import 'package:gw_community/ui/learn/content_view/content_view.dart';
import 'package:gw_community/ui/learn/themes/learn_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Card unificado que exibe tanto recordings quanto activities
class UnifiedFavoriteCard extends StatefulWidget {
  const UnifiedFavoriteCard({
    super.key,
    required this.item,
    this.onUnfavorite,
  });

  final UnifiedFavoriteItem item;
  final VoidCallback? onUnfavorite;

  @override
  State<UnifiedFavoriteCard> createState() => _UnifiedFavoriteCardState();
}

class _UnifiedFavoriteCardState extends State<UnifiedFavoriteCard> {
  int _favoriteVersion = 0;

  Future<void> _handleTap(BuildContext context) async {
    if (widget.item.isRecording) {
      await _openRecording(context);
    } else {
      _openActivity(context);
    }
  }

  Future<void> _openRecording(BuildContext context) async {
    final recording = widget.item.recording!;

    // Capturar valores antes do async gap
    final repository = context.read<FavoritesRepository>();
    final currentUserId = context.currentUserIdOrEmpty;

    // Converte para ViewContentRow para compatibilidade com ContentView
    final viewContentRow = ViewContentRow({
      'content_id': recording.contentId,
      'title': recording.title,
      'description': recording.description,
      'authors_names': recording.authorsNames,
      'midia_type': recording.midiaType,
      'audio_url': recording.audioUrl,
      'midia_file_url': recording.midiaFileUrl,
      'cott_event_id': recording.cottEventId,
      'event_name': recording.eventName,
    });

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
              contentId: recording.contentId!,
              viewContentRow: viewContentRow,
            ),
          ),
        );
      },
    );

    // Após fechar o modal, verificar se ainda está favoritado
    if (mounted && currentUserId.isNotEmpty) {
      final isFavorite = await repository.isFavorite(
        authUserId: currentUserId,
        contentType: FavoritesRepository.typeRecording,
        contentId: recording.contentId!,
      );

      // Se foi desfavoritado no modal, remover da lista
      if (!isFavorite && mounted) {
        widget.onUnfavorite?.call();
      } else if (mounted) {
        // Apenas atualizar o ícone se ainda estiver favoritado
        setState(() {
          _favoriteVersion++;
        });
      }
    }
  }

  void _openActivity(BuildContext context) {
    final activity = widget.item.activity!;

    if (activity.activityType == 'audio') {
      context.pushNamed(
        StepAudioPlayerPage.routeName,
        queryParameters: {
          'stepAudioUrl': serializeParam(activity.audioUrl, ParamType.String),
          'audioTitle': serializeParam(activity.activityPrompt, ParamType.String),
          'typeAnimation': serializeParam('IN', ParamType.String),
          'audioArt': serializeParam(
            'https://firebasestorage.googleapis.com/v0/b/good-wishes-project.appspot.com/o/images%2Fic_goodwishes.png?alt=media&token=e441f239-c823-468b-bff7-c16be921c7be',
            ParamType.String,
          ),
          'typeStep': serializeParam(activity.activityLabel, ParamType.String),
          'activityId': serializeParam(activity.id, ParamType.int),
        }.withoutNulls,
      );
    } else if (activity.activityType == 'text') {
      context.pushNamed(
        StepTextViewPage.routeName,
        queryParameters: {
          'stepTextTitle': serializeParam(activity.activityPrompt, ParamType.String),
          'stepTextContent': serializeParam(activity.text, ParamType.String),
          'activityId': serializeParam(activity.id, ParamType.int),
        }.withoutNulls,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 6.0, 16.0, 6.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                widget.item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).learn.contentTitle.override(
                      color: AppTheme.of(context).secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              // Autor (apenas para recordings)
              if (widget.item.isRecording && widget.item.recording!.authorsNames.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Text(
                  widget.item.recording!.authorsNames.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.of(context).learn.metadata.override(
                        color: AppTheme.of(context).secondary,
                        fontSize: 12.0,
                      ),
                ),
              ],
              const SizedBox(height: 6.0),
              // Descrição
              if (widget.item.description != null && widget.item.description!.isNotEmpty)
                Text(
                  widget.item.description!.maybeHandleOverflow(
                    maxChars: 120,
                    replacement: '…',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.of(context).learn.bodyLight.override(
                        color: AppTheme.of(context).secondary,
                        fontSize: 12.0,
                      ),
                ),
              const SizedBox(height: 10.0),
              // Tags + Favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tags
                  Expanded(
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: _buildTags(context),
                    ),
                  ),
                  // Favorito
                  if (context.currentUserIdOrEmpty.isNotEmpty)
                    FavoriteButton(
                      key: ValueKey('favorite_${widget.item.contentId}_$_favoriteVersion'),
                      contentType: widget.item.isRecording
                          ? FavoritesRepository.typeRecording
                          : FavoritesRepository.typeActivity,
                      contentId: widget.item.contentId,
                      authUserId: context.currentUserIdOrEmpty,
                      size: 20.0,
                      initialIsFavorite: true,
                      onToggle: (isFavorite) {
                        if (!isFavorite && mounted) {
                          widget.onUnfavorite?.call();
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTags(BuildContext context) {
    final tags = <Widget>[];

    // Tag de origem (From Library ou From Journey)
    String originLabel = 'From Library';
    if (widget.item.isActivity) {
      final title = widget.item.journeyTitle;
      originLabel = title != null ? 'From $title' : 'From Journey';
    }

    tags.add(_CategoryTag(
      label: originLabel,
      context: context,
      isPrimary: false,
    ));

    // Tag de tipo de mídia
    if (widget.item.mediaType != null) {
      String label;
      if (widget.item.mediaType == 'audio') {
        label = 'Audio';
      } else if (widget.item.mediaType == 'video') {
        label = 'Video';
      } else if (widget.item.mediaType == 'text') {
        label = 'Text';
      } else if (widget.item.mediaType == 'journal') {
        label = 'Journal';
      } else {
        label = widget.item.mediaType!;
      }

      tags.add(_CategoryTag(
        label: label,
        context: context,
        isPrimary: true,
      ));
    }

    return tags;
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({
    required this.label,
    required this.context,
    required this.isPrimary,
  });

  final String label;
  final BuildContext context;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.of(context).primary.withValues(alpha: 0.15)
            : AppTheme.of(context).secondaryText.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? AppTheme.of(context).primary : AppTheme.of(context).secondary,
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
