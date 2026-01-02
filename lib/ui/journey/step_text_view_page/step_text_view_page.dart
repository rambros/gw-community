import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';

class StepTextViewPage extends StatelessWidget {
  const StepTextViewPage({
    super.key,
    this.stepTextTitle,
    this.stepTextContent,
    this.activityId,
  });

  final String? stepTextTitle;
  final String? stepTextContent;
  final int? activityId;

  static String routeName = 'stepTextViewPage';
  static String routePath = '/stepTextViewPage';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.of(context).secondary,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Daily Practice',
            style: AppTheme.of(context).journey.pageTitle,
          ),
          actions: [
            if (context.currentUserIdOrEmpty.isNotEmpty && activityId != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                child: FavoriteButton(
                  contentType: FavoritesRepository.typeActivity,
                  contentId: activityId!,
                  authUserId: context.currentUserIdOrEmpty,
                  size: 28.0,
                  iconColor: Colors.white,
                ),
              ),
          ],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondary,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            stepTextTitle ?? 'prompt',
                            textAlign: TextAlign.center,
                            style: AppTheme.of(context).journey.stepTitle.override(
                                  color: AppTheme.of(context).tertiary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SelectionArea(
                      child: MarkdownBody(
                        data: stepTextContent ?? 'text',
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            height: 1.5,
                          ),
                          strong: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                          em: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                          h1: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).tertiary,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).tertiary,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).tertiary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                          listBullet: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
