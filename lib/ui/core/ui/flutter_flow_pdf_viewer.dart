import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/domain/community/pdf_reading_text.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/reading_text_size.dart';
import 'package:pdfrx/pdfrx.dart';

class FlutterFlowPdfViewer extends StatefulWidget {
  const FlutterFlowPdfViewer({
    super.key,
    this.networkPath,
    this.assetPath,
    this.fileBytes,
    this.width,
    this.height,
    this.horizontalScroll = false,
  }) : assert(
            (networkPath != null) ^ (assetPath != null) ^ (fileBytes != null));

  final String? networkPath;
  final String? assetPath;
  final Uint8List? fileBytes;
  final double? width;
  final double? height;
  final bool horizontalScroll;

  @override
  State<FlutterFlowPdfViewer> createState() => _FlutterFlowPdfViewerState();
}

class _FlutterFlowPdfViewerState extends State<FlutterFlowPdfViewer> {
  bool _reading = true;
  int _fontIndex = readingFontDefaultIndex;
  bool _loading = true;
  bool _failed = false;
  String? _text;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _restoreFontSize();
    _loadReadingText();
  }

  @override
  void didUpdateWidget(FlutterFlowPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.networkPath != widget.networkPath ||
        oldWidget.assetPath != widget.assetPath ||
        oldWidget.fileBytes != widget.fileBytes) {
      _text = null;
      _failed = false;
      _loading = _reading;
      if (_reading) _loadReadingText();
    }
  }

  Future<void> _restoreFontSize() async {
    final index = await ReadingTextSizeStore.loadIndex();
    if (!mounted || index == _fontIndex) return;
    setState(() => _fontIndex = index);
  }

  Future<void> _storeFontSize() async {
    await ReadingTextSizeStore.storeSize(readingFontSizes[_fontIndex]);
  }

  void _setReading(bool reading) {
    if (_reading == reading) return;
    final needsText = reading && _text == null;
    setState(() {
      _reading = reading;
      if (needsText) {
        _loading = true;
        _failed = false;
      }
    });
    if (needsText) _loadReadingText();
  }

  void _changeFontSize(int delta) {
    final next = (_fontIndex + delta).clamp(0, readingFontSizes.length - 1);
    if (next == _fontIndex) return;
    setState(() => _fontIndex = next);
    _storeFontSize();
  }

  Future<void> _loadReadingText() async {
    final generation = ++_loadGeneration;
    _loading = true;
    _failed = false;
    try {
      final text = await _extractReadingText();
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _text = text;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _text = null;
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<String> _extractReadingText() async {
    final document = await _openDocument();
    try {
      final pages = <List<PdfTextRun>>[];
      for (final page in document.pages) {
        final structured = await page.loadStructuredText();
        pages.add(_runsFromPage(structured));
      }
      return reflowPdfPages(pages);
    } finally {
      await document.dispose();
    }
  }

  Future<PdfDocument> _openDocument() {
    final networkPath = widget.networkPath;
    if (networkPath != null && networkPath.isNotEmpty) {
      return PdfDocument.openUri(Uri.parse(networkPath));
    }
    final assetPath = widget.assetPath;
    if (assetPath != null && assetPath.isNotEmpty) {
      return PdfDocument.openAsset(assetPath);
    }
    return PdfDocument.openData(
      widget.fileBytes!,
      sourceName: networkPath ?? assetPath ?? 'fileBytes',
    );
  }

  List<PdfTextRun> _runsFromPage(PdfPageText page) {
    if (page.fragments.isEmpty) {
      if (page.fullText.trim().isEmpty) return const [];
      return [
        PdfTextRun(
          text: page.fullText,
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
        ),
      ];
    }
    return [
      for (final fragment in page.fragments)
        PdfTextRun(
          text: fragment.text,
          left: fragment.bounds.left,
          top: fragment.bounds.top,
          right: fragment.bounds.right,
          bottom: fragment.bounds.bottom,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadingToolbar(
            reading: _reading,
            fontIndex: _fontIndex,
            onPage: () => _setReading(false),
            onReading: () => _setReading(true),
            onDecrease: () => _changeFontSize(-1),
            onIncrease: () => _changeFontSize(1),
          ),
          Expanded(child: _reading ? _buildReading(context) : _buildPage()),
        ],
      ),
    );
  }

  Widget _buildReading(BuildContext context) {
    final l10n = context.l10n;
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _failed
            ? _ReadingMessage(text: l10n.pdfReadingFailed)
            : (_text ?? '').trim().isEmpty
                ? _ReadingMessage(text: l10n.pdfReadingEmpty)
                : Scrollbar(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: SelectableText(
                        _text!,
                        style: GoogleFonts.lexendDeca(
                          fontSize: readingFontSizes[_fontIndex],
                          height: 1.45,
                          color: GWPalette.textDark,
                        ),
                      ),
                    ),
                  );

    return ColoredBox(
      color: AppTheme.of(context).primaryBackground,
      child: body,
    );
  }

  Widget _buildPage() {
    final params = PdfViewerParams(
      layoutPages: widget.horizontalScroll ? _horizontalLayout : null,
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
          const Center(child: CircularProgressIndicator()),
      errorBannerBuilder: (context, error, stackTrace, documentRef) =>
          Container(),
    );

    final networkPath = widget.networkPath;
    final assetPath = widget.assetPath;
    final fileBytes = widget.fileBytes;
    final viewer = networkPath != null && networkPath.isNotEmpty
        ? PdfViewer.uri(Uri.parse(networkPath), params: params)
        : assetPath != null && assetPath.isNotEmpty
            ? PdfViewer.asset(assetPath, params: params)
            : fileBytes != null && fileBytes.isNotEmpty
                ? PdfViewer.data(
                    fileBytes,
                    sourceName: networkPath ?? assetPath ?? 'fileBytes',
                    params: params,
                  )
                : null;

    return viewer ?? const SizedBox();
  }

  static PdfPageLayout _horizontalLayout(
      List<PdfPage> pages, PdfViewerParams params) {
    final height = pages.fold(0.0, (prev, page) => max(prev, page.height)) +
        params.margin * 2;
    final pageLayouts = <Rect>[];
    double x = params.margin;
    for (final page in pages) {
      pageLayouts.add(Rect.fromLTWH(
          x, (height - page.height) / 2, page.width, page.height));
      x += page.width + params.margin;
    }
    return PdfPageLayout(
        pageLayouts: pageLayouts, documentSize: Size(x, height));
  }
}

class _ReadingToolbar extends StatelessWidget {
  const _ReadingToolbar({
    required this.reading,
    required this.fontIndex,
    required this.onPage,
    required this.onReading,
    required this.onDecrease,
    required this.onIncrease,
  });

  final bool reading;
  final int fontIndex;
  final VoidCallback onPage;
  final VoidCallback onReading;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = AppTheme.of(context);
    return Material(
      color: theme.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _ModeButton(
              label: l10n.pdfViewPage,
              selected: !reading,
              onPressed: onPage,
            ),
            const SizedBox(width: 4),
            _ModeButton(
              label: l10n.pdfViewReading,
              selected: reading,
              onPressed: onReading,
            ),
            const Spacer(),
            if (reading)
              ReadingTextSizeButtons(
                fontIndex: fontIndex,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: selected ? theme.primary : Colors.transparent,
        foregroundColor: selected ? Colors.white : theme.secondary,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(label),
    );
  }
}

class _ReadingMessage extends StatelessWidget {
  const _ReadingMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexendDeca(
            fontSize: 16,
            height: 1.4,
            color: GWPalette.textDark,
          ),
        ),
      ),
    );
  }
}
