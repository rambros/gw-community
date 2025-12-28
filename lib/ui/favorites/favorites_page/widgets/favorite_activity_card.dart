import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/utils/context_extensions.dart';

/// Card de activity favorita
class FavoriteActivityCard extends StatelessWidget {
  const FavoriteActivityCard({
    super.key,
    required this.activity,
    this.onUnfavorite,
    this.onTap,
  });

  final CcViewUserFavoriteActivitiesRow activity;
  final VoidCallback? onUnfavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Activity type icon
                _buildActivityIcon(context),
                const SizedBox(width: 12.0),
                // Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityLabel ?? 'Activity',
                        style: AppTheme.of(context).bodyLarge.override(
                              color: AppTheme.of(context).primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        activity.activityPrompt ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                              fontSize: 13.0,
                            ),
                      ),
                    ],
                  ),
                ),
                // Favorite button
                if (context.currentUserIdOrEmpty.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: FavoriteButton(
                      contentType: FavoritesRepository.typeActivity,
                      contentId: activity.id,
                      authUserId: context.currentUserIdOrEmpty,
                      size: 22.0,
                      initialIsFavorite: true,
                      onToggle: (isFavorite) {
                        if (!isFavorite) {
                          onUnfavorite?.call();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon(BuildContext context) {
    final iconColor = AppTheme.of(context).primary;

    if (activity.activityType == 'audio') {
      return Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.play_circle_outlined,
            color: iconColor,
            size: 28.0,
          ),
        ),
      );
    } else if (activity.activityType == 'text') {
      return Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.text_snippet_outlined,
            color: iconColor,
            size: 28.0,
          ),
        ),
      );
    } else {
      return Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.solidPenToSquare,
            color: iconColor,
            size: 24.0,
          ),
        ),
      );
    }
  }
}
