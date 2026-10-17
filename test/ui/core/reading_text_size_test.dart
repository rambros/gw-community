import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/ui/core/ui/reading_text_size.dart';

void main() {
  test('readingFontIndexFor uses the default step when nothing is stored', () {
    expect(readingFontIndexFor(null), readingFontDefaultIndex);
    expect(readingFontSizes[readingFontDefaultIndex], 18);
  });

  test('readingFontIndexFor matches a stored step', () {
    expect(readingFontIndexFor(26), 4);
    expect(readingFontSizes[4], 26);
  });

  test('readingFontIndexFor falls back when the stored size is unknown', () {
    expect(readingFontIndexFor(15), readingFontDefaultIndex);
  });

  test('markdown headings stay a fixed step above the body', () {
    expect(readingMarkdownHeadingSize(18, 3), 20);
    expect(readingMarkdownHeadingSize(18, 2), 22);
    expect(readingMarkdownHeadingSize(18, 1), 26);
  });
}
