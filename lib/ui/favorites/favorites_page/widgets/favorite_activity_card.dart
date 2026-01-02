import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/learn/themes/learn_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:gw_community/routing/router.dart';
import 'package:gw_community/ui/journey/step_audio_player_page/step_audio_player_page.dart';
import 'package:gw_community/ui/journey/step_text_view_page/step_text_view_page.dart';

/// Card de activity favorita (redesenhado com novo layout)
class FavoriteActivityCard extends StatefulWidget {
  const FavoriteActivityCard({
    super.key,
    required this.activity,
    this.onUnfavorite,
  });

  final CcViewUserFavoriteActivitiesRow activity;
  final VoidCallback? onUnfavorite;

  @override
  State<FavoriteActivityCard> createState() => _FavoriteActivityCardState();
}

class _FavoriteActivityCardState extends State<FavoriteActivityCard> {
  int _favoriteVersion = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 6.0, 16.0, 6.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.activity.activityType == 'audio') {
            context.pushNamed(
              StepAudioPlayerPage.routeName,
              queryParameters: {
                'stepAudioUrl': serializeParam(widget.activity.audioUrl, ParamType.String),
                'audioTitle': serializeParam(widget.activity.activityPrompt, ParamType.String),
                'typeAnimation': serializeParam('IN', ParamType.String),
                'audioArt': serializeParam(
                  'https://firebasestorage.googleapis.com/v0/b/good-wishes-project.appspot.com/o/images%2Fic_goodwishes.png?alt=media&token=e441f239-c823-468b-bff7-c16be921c7be',
                  ParamType.String,
                ),
                'typeStep': serializeParam(widget.activity.activityLabel, ParamType.String),
                'activityId': serializeParam(widget.activity.id, ParamType.int),
              }.withoutNulls,
            );
          } else if (widget.activity.activityType == 'text') {
            context.pushNamed(
              StepTextViewPage.routeName,
              queryParameters: {
                'stepTextTitle': serializeParam(widget.activity.activityPrompt, ParamType.String),
                'stepTextContent': serializeParam(widget.activity.text, ParamType.String),
                'activityId': serializeParam(widget.activity.id, ParamType.int),
              }.withoutNulls,
            );
          }
        },
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
                valueOrDefault<String>(widget.activity.activityLabel, 'Activity'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).learn.contentTitle.override(
                      color: AppTheme.of(context).secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6.0),
              // Descrição
              Text(
                valueOrDefault<String>(widget.activity.activityPrompt, '').maybeHandleOverflow(
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
              // Tags de tipo + Favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tag de tipo de activity
                  _buildActivityTypeTag(context),
                  // Favorito
                  if (context.currentUserIdOrEmpty.isNotEmpty)
                    FavoriteButton(
                      key: ValueKey('favorite_${widget.activity.id}_$_favoriteVersion'),
                      contentType: FavoritesRepository.typeActivity,
                      contentId: widget.activity.id,
                      authUserId: context.currentUserIdOrEmpty,
                      size: 20.0,
                      initialIsFavorite: true,
                      onToggle: (isFavorite) {
                        if (!isFavorite && mounted) {
                          // Remove da lista quando desfavoritar
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

  Widget _buildActivityTypeTag(BuildContext context) {
    String label;

    if (widget.activity.activityType == 'audio') {
      label = 'Audio';
    } else if (widget.activity.activityType == 'text') {
      label = 'Text';
    } else if (widget.activity.activityType == 'journal') {
      label = 'Journal';
    } else {
      label = 'Activity';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.of(context).primary,
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
