import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Opens an external URL inside the app (instead of kicking the user out to
/// the system browser), with a back button that returns to the previous
/// screen. Useful for things like event registration forms.
class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  WebViewXController? _webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title ?? 'Event Link',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(
                  fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                  fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                ),
                color: AppTheme.of(context).primaryBackground,
                fontSize: 20.0,
                letterSpacing: 0.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
      ),
      body: WebViewAware(
        child: Stack(
          children: [
            WebViewX(
              initialContent: widget.url,
              initialSourceType: SourceType.url,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              onWebViewCreated: (controller) => _webViewController = controller,
              onPageStarted: (_) => setState(() => _isLoading = true),
              onPageFinished: (_) => setState(() => _isLoading = false),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.of(context).primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
