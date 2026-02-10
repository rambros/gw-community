import 'package:flutter/material.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/community_guidelines_page/community_guidelines_page.dart';
import 'package:gw_community/ui/profile/user_profile_page/widgets/profile_menu_item_widget.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuItemWidget(
          text: 'My Favorites',
          onTap: () async {
            context.pushNamed(
              FavoritesPage.routeName,
              extra: <String, dynamic>{
                kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'My Journal',
            onTap: () async {
              context.pushNamed(
                UserJournalListPage.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'My Journeys',
            onTap: () async {
              context.pushNamed(
                UserJourneysViewPage.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'My Experiences',
            onTap: () async {
              context.pushNamed(MyExperiencesPage.routeName);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'Ask a Question',
            onTap: () async {
              context.pushNamed(SupportPage.routeName);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
          child: ProfileMenuItemWidget(
            text: 'Community Guidelines',
            onTap: () async {
              context.pushNamed(
                CommunityGuidelinesPage.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
