import 'package:flutter/material.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/transcript_markdown.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';

/// Full-screen transcript reader. Only the app bar stays pinned.
class TranscriptReadingPage extends StatelessWidget {
  const TranscriptReadingPage({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.data,
  });

  final String appBarTitle;
  final String title;
  final String data;

  static Future<void> open(
    BuildContext context, {
    required String appBarTitle,
    required String title,
    required String data,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => TranscriptReadingPage(
          appBarTitle: appBarTitle,
          title: title,
          data: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          appBarTitle,
          style: theme.journey.pageTitle.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.journey.stepTitle.copyWith(
                color: theme.secondary,
              ),
            ),
            const SizedBox(height: 20.0),
            TranscriptMarkdown(
              data: data,
              textColor: theme.textColor,
            ),
          ],
        ),
      ),
    );
  }
}
