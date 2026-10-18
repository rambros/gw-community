import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/pinch_zoom_image.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class StepImagePage extends StatelessWidget {
  const StepImagePage({
    super.key,
    required this.activityRow,
    this.fixedLanguage,
  });

  final CcViewUserActivitiesRow? activityRow;
  final String? fixedLanguage;

  static String routeName = 'stepImagePage';
  static String routePath = '/stepImagePage';

  @override
  Widget build(BuildContext context) {
    final activity = activityRow;
    final title = (activity?.activityPrompt ?? '').trim();
    final reflection = (activity?.text ?? '').trim();
    final imageUrl = (activity?.imageUrl ?? '').trim();

    return JourneyLocaleScope(
      fixedLanguage: fixedLanguage,
      builder: (context) => Scaffold(
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
            onPressed: () => context.pop(),
          ),
          title: Text(
            context.l10n.activityImageTitle,
            style: AppTheme.of(context).journey.pageTitle,
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).journey.stepTitle.override(
                          color: AppTheme.of(context).tertiary,
                        ),
                  ),
                if (imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Expanded(child: PinchZoomImage(imageUrl: imageUrl)),
                ],
                if (reflection.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.28,
                    ),
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: reflection,
                        selectable: true,
                        softLineBreak: true,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16.0,
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
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
