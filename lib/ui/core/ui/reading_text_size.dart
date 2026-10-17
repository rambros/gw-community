import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const readingFontSizes = <double>[16, 18, 20, 22, 26, 30, 36];
const readingFontSizeKey = 'reading_font_size';
const legacyPdfReadingFontSizeKey = 'pdf_reading_font_size';

const readingFontDefaultIndex = 1;

int readingFontIndexFor(double? stored) {
  if (stored == null) return readingFontDefaultIndex;
  final index =
      readingFontSizes.indexWhere((size) => (size - stored).abs() < 0.1);
  return index < 0 ? readingFontDefaultIndex : index;
}

/// Heading sizes stay a fixed step above the chosen body size.
double readingMarkdownHeadingSize(double bodySize, int level) {
  return bodySize +
      switch (level) {
        1 => 8,
        2 => 4,
        _ => 2,
      };
}

class ReadingTextSizeStore {
  static Future<int> loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(readingFontSizeKey) ??
        prefs.getDouble(legacyPdfReadingFontSizeKey);
    return readingFontIndexFor(stored);
  }

  static Future<void> storeSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(readingFontSizeKey, size);
  }
}

class ReadingTextSizeButtons extends StatelessWidget {
  const ReadingTextSizeButtons({
    super.key,
    required this.fontIndex,
    required this.onDecrease,
    required this.onIncrease,
    this.color,
    this.disabledColor,
  });

  final int fontIndex;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final Color? color;
  final Color? disabledColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = AppTheme.of(context);
    final canDecrease = fontIndex > 0;
    final canIncrease = fontIndex < readingFontSizes.length - 1;
    final enabled = color ?? theme.secondary;
    final disabled = disabledColor ?? theme.secondaryText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ReadingSizeButton(
          label: 'A−',
          tooltip: l10n.pdfDecreaseTextSize,
          onPressed: canDecrease ? onDecrease : null,
          color: canDecrease ? enabled : disabled,
        ),
        _ReadingSizeButton(
          label: 'A+',
          tooltip: l10n.pdfIncreaseTextSize,
          onPressed: canIncrease ? onIncrease : null,
          color: canIncrease ? enabled : disabled,
          fontSize: 18,
        ),
      ],
    );
  }
}

class _ReadingSizeButton extends StatelessWidget {
  const _ReadingSizeButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
    required this.color,
    this.fontSize,
  });

  final String label;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class ReadingTextSizeBar extends StatelessWidget {
  const ReadingTextSizeBar({
    super.key,
    required this.fontIndex,
    required this.onDecrease,
    required this.onIncrease,
    this.backgroundColor,
    this.buttonColor,
    this.disabledButtonColor,
  });

  final int fontIndex;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? disabledButtonColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppTheme.of(context).secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 2),
        child: Row(
          children: [
            const Spacer(),
            ReadingTextSizeButtons(
              fontIndex: fontIndex,
              onDecrease: onDecrease,
              onIncrease: onIncrease,
              color: buttonColor,
              disabledColor: disabledButtonColor,
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingTextSize extends StatefulWidget {
  const ReadingTextSize({
    super.key,
    required this.builder,
    this.barColor,
    this.buttonColor,
    this.disabledButtonColor,
  });

  final Widget Function(
    BuildContext context,
    double fontSize,
    Widget controls,
  ) builder;
  final Color? barColor;
  final Color? buttonColor;
  final Color? disabledButtonColor;

  @override
  State<ReadingTextSize> createState() => _ReadingTextSizeState();
}

class _ReadingTextSizeState extends State<ReadingTextSize> {
  int _fontIndex = readingFontDefaultIndex;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final index = await ReadingTextSizeStore.loadIndex();
    if (!mounted || index == _fontIndex) return;
    setState(() => _fontIndex = index);
  }

  void _change(int delta) {
    final next = (_fontIndex + delta).clamp(0, readingFontSizes.length - 1);
    if (next == _fontIndex) return;
    setState(() => _fontIndex = next);
    ReadingTextSizeStore.storeSize(readingFontSizes[next]);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      readingFontSizes[_fontIndex],
      ReadingTextSizeBar(
        fontIndex: _fontIndex,
        onDecrease: () => _change(-1),
        onIncrease: () => _change(1),
        backgroundColor: widget.barColor,
        buttonColor: widget.buttonColor,
        disabledButtonColor: widget.disabledButtonColor,
      ),
    );
  }
}
