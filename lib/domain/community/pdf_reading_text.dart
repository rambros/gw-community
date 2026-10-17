import 'dart:math' as math;

/// One text run extracted from a PDF page, in reading order.
///
/// Coordinates follow PDF space: the origin is the bottom-left and [top] is
/// greater than [bottom]. A run whose text is only a line break separates lines.
class PdfTextRun {
  const PdfTextRun({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
}

/// Joins visual PDF lines into paragraphs that wrap to the screen width.
///
/// Each inner list is one page. Pages are separated by a blank line.
String reflowPdfPages(List<List<PdfTextRun>> pages) {
  final blocks = <String>[];
  for (final page in pages) {
    final text = _reflowPage(page).trim();
    if (text.isNotEmpty) blocks.add(text);
  }
  return blocks.join('\n\n');
}

class _Line {
  const _Line({
    required this.text,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  const _Line.empty()
      : text = '',
        top = 0,
        bottom = 0,
        left = 0,
        right = 0;

  final String text;
  final double top;
  final double bottom;
  final double left;
  final double right;

  double get height => math.max(0, top - bottom);
  bool get isEmpty => text.trim().isEmpty;
}

String _reflowPage(List<PdfTextRun> runs) {
  final lines = _linesFromRuns(runs);
  if (lines.isEmpty) return '';

  final maxRight = lines.fold<double>(
    0,
    (maxRight, line) =>
        line.isEmpty ? maxRight : math.max(maxRight, line.right),
  );

  final paragraphs = <String>[];
  final current = StringBuffer();
  _Line? previous;

  void endParagraph() {
    final text = current.toString().trim();
    current.clear();
    previous = null;
    if (text.isNotEmpty) paragraphs.add(text);
  }

  for (final line in lines) {
    if (line.isEmpty) {
      endParagraph();
      continue;
    }
    final trimmed = line.text.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
    if (previous == null || current.isEmpty) {
      current.write(trimmed);
    } else if (_continuesParagraph(previous!, line)) {
      _appendWrapped(
        current,
        trimmed,
        dropHyphen: _isSoftLineBreakHyphen(previous!, maxRight),
      );
    } else {
      endParagraph();
      current.write(trimmed);
    }
    previous = line;
  }
  endParagraph();
  return paragraphs.join('\n\n');
}

List<_Line> _linesFromRuns(List<PdfTextRun> runs) {
  final lines = <_Line>[];
  final buffer = StringBuffer();
  double? top;
  double? bottom;
  double? left;
  double? right;

  void flush({required bool fromBreak}) {
    final raw = buffer.toString().replaceAll('\u00ad', '');
    buffer.clear();
    if (top != null && raw.trim().isNotEmpty) {
      lines.add(_Line(
        text: raw,
        top: top!,
        bottom: bottom!,
        left: left!,
        right: right!,
      ));
    } else if (fromBreak && lines.isNotEmpty && !lines.last.isEmpty) {
      lines.add(const _Line.empty());
    }
    top = bottom = left = right = null;
  }

  void addPiece(String text, PdfTextRun run) {
    if (text.isEmpty) return;
    top = top == null ? run.top : math.max(top!, run.top);
    bottom = bottom == null ? run.bottom : math.min(bottom!, run.bottom);
    left = left == null ? run.left : math.min(left!, run.left);
    right = right == null ? run.right : math.max(right!, run.right);
    buffer.write(text);
  }

  for (final run in runs) {
    final parts = run.text.split(RegExp(r'\r?\n|\r'));
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) flush(fromBreak: true);
      addPiece(parts[i], run);
    }
  }
  flush(fromBreak: false);
  return lines;
}

bool _continuesParagraph(_Line previous, _Line line) {
  final lineHeight = math.max(previous.height, line.height);
  if (lineHeight <= 0) return true;
  final gap = previous.bottom - line.top;
  return gap < lineHeight * 0.65;
}

final _letterHyphen = RegExp(r'\p{L}-$', unicode: true);

bool _isSoftLineBreakHyphen(_Line line, double maxRight) {
  final trimmed = line.text.trimRight();
  if (!_letterHyphen.hasMatch(trimmed)) return false;
  return maxRight - line.right < 36;
}

void _appendWrapped(
  StringBuffer current,
  String next, {
  required bool dropHyphen,
}) {
  final existing = current.toString();
  if (dropHyphen) {
    current
      ..clear()
      ..write(existing.replaceFirst(RegExp(r'-$'), ''))
      ..write(next);
    return;
  }
  if (_letterHyphen.hasMatch(existing.trimRight())) {
    current.write(next);
    return;
  }
  current
    ..write(' ')
    ..write(next);
}
