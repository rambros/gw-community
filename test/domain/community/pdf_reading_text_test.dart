import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/pdf_reading_text.dart';

PdfTextRun run(
  String text, {
  required double top,
  required double bottom,
  double left = 40,
  double right = 200,
}) {
  return PdfTextRun(
    text: text,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
}

void main() {
  group('reflowPdfPages', () {
    test('joins wrapped lines that sit on the next leading', () {
      final text = reflowPdfPages([
        [
          run('A leitura fica', top: 100, bottom: 88, right: 220),
          run('\n', top: 88, bottom: 88, right: 220),
          run('dentro da tela.', top: 84, bottom: 72, right: 180),
        ],
      ]);

      expect(text, 'A leitura fica dentro da tela.');
    });

    test('starts a new paragraph when the gap is larger than the leading', () {
      final text = reflowPdfPages([
        [
          run('Primeiro parágrafo.', top: 100, bottom: 88),
          run('\n', top: 88, bottom: 88),
          run('Segundo parágrafo.', top: 60, bottom: 48),
        ],
      ]);

      expect(text, 'Primeiro parágrafo.\n\nSegundo parágrafo.');
    });

    test('drops a hyphen that only exists to break the line', () {
      final text = reflowPdfPages([
        [
          run('comunica-', top: 100, bottom: 88, right: 400),
          run('\n', top: 88, bottom: 88, right: 400),
          run('ção', top: 84, bottom: 72, right: 80),
        ],
      ]);

      expect(text, 'comunicação');
    });

    test('keeps a hyphen that belongs to the word', () {
      final text = reflowPdfPages([
        [
          run('bem-', top: 100, bottom: 88, right: 80),
          run('\n', top: 88, bottom: 88, right: 80),
          run('estar', top: 84, bottom: 72, right: 140),
        ],
      ]);

      expect(text, 'bem-estar');
    });

    test('treats a blank line as a paragraph break', () {
      final text = reflowPdfPages([
        [
          run('Um', top: 100, bottom: 88),
          run('\n\n', top: 88, bottom: 70),
          run('Dois', top: 66, bottom: 54),
        ],
      ]);

      expect(text, 'Um\n\nDois');
    });

    test('separates pages with a blank line', () {
      final text = reflowPdfPages([
        [run('Página um', top: 100, bottom: 88)],
        [run('Página dois', top: 100, bottom: 88)],
      ]);

      expect(text, 'Página um\n\nPágina dois');
    });
  });
}
