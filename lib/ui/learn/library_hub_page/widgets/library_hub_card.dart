import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

enum LibraryHubGlyph {
  dialogues,
  heartToHeart,
  dadiJanki,
  meditations,
  wordsOfWisdom,
}

class LibraryHubCardData {
  const LibraryHubCardData({
    required this.title,
    required this.glyph,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final LibraryHubGlyph glyph;
  final List<Color> gradient;
  final VoidCallback onTap;
}

class LibraryHubCard extends StatelessWidget {
  const LibraryHubCard({
    super.key,
    required this.data,
    this.isWide = false,
  });

  final LibraryHubCardData data;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14.0,
            color: Color(0x24000000),
            offset: Offset(0.0, 7.0),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: data.onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradient,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final baseIconSize = constraints.biggest.shortestSide * 0.42;
                final iconSize = isWide
                    ? constraints.maxHeight *
                        (data.glyph == LibraryHubGlyph.meditations
                            ? 0.78
                            : 0.52)
                    : data.glyph == LibraryHubGlyph.dadiJanki ||
                            data.glyph == LibraryHubGlyph.meditations
                        ? baseIconSize * 1.25
                        : data.glyph == LibraryHubGlyph.heartToHeart
                            ? baseIconSize * 1.12
                            : data.glyph == LibraryHubGlyph.wordsOfWisdom
                                ? baseIconSize * 1.10
                                : baseIconSize;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _HubBackgroundPainter(data.glyph),
                      ),
                      if (isWide)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Transform.translate(
                            offset: Offset(
                              data.glyph == LibraryHubGlyph.meditations
                                  ? 8.0
                                  : 0.0,
                              0.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CardGlyph(glyph: data.glyph, size: iconSize),
                                const SizedBox(width: 24.0),
                                Flexible(child: _CardTitle(title: data.title)),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: baseIconSize * 1.25,
                                child: Align(
                                  alignment:
                                      data.glyph == LibraryHubGlyph.heartToHeart
                                          ? Alignment.bottomCenter
                                          : Alignment.center,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      data.glyph == LibraryHubGlyph.heartToHeart
                                          ? baseIconSize * 0.08
                                          : 0,
                                    ),
                                    child: _CardGlyph(
                                      glyph: data.glyph,
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: baseIconSize * 0.16),
                              _CardTitle(title: data.title),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CardGlyph extends StatelessWidget {
  const _CardGlyph({required this.glyph, required this.size});

  final LibraryHubGlyph glyph;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HubGlyphPainter(glyph)),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.of(context).titleMedium.override(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            lineHeight: 1.2,
          ),
    );
  }
}

class _HubGlyphPainter extends CustomPainter {
  const _HubGlyphPainter(this.glyph);

  final LibraryHubGlyph glyph;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeScale = switch (glyph) {
      LibraryHubGlyph.dadiJanki => 0.8,
      LibraryHubGlyph.meditations => 0.72,
      _ => 1.0,
    };
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.048 * strokeScale).clamp(2.0, 3.2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    switch (glyph) {
      case LibraryHubGlyph.dialogues:
        _paintBook(canvas, size, stroke);
      case LibraryHubGlyph.heartToHeart:
        _paintHearts(canvas, size, stroke);
      case LibraryHubGlyph.dadiJanki:
        _paintPerson(canvas, size, stroke);
      case LibraryHubGlyph.meditations:
        _paintLotus(canvas, size, stroke);
      case LibraryHubGlyph.wordsOfWisdom:
        _paintWisdom(canvas, size, stroke);
    }
  }

  void _paintRays(
    Canvas canvas,
    Offset origin,
    Paint paint, {
    required int count,
    required double inner,
    required double outer,
    required double startAngle,
    required double sweep,
  }) {
    for (var i = 0; i < count; i++) {
      final t = count == 1 ? 0.5 : i / (count - 1);
      final angle = startAngle + sweep * t;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(origin + dir * inner, origin + dir * outer, paint);
    }
  }

  void _paintBook(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final top = h * 0.48;
    final bottom = h * 0.88;

    _paintRays(
      canvas,
      Offset(cx, h * 0.47),
      paint,
      count: 5,
      inner: h * 0.19,
      outer: h * 0.31,
      startAngle: -math.pi * 0.78,
      sweep: math.pi * 0.56,
    );

    final left = Path()
      ..moveTo(cx, top)
      ..cubicTo(
        w * 0.40,
        top - h * 0.05,
        w * 0.27,
        top - h * 0.04,
        w * 0.17,
        top + h * 0.02,
      )
      ..lineTo(w * 0.17, bottom)
      ..cubicTo(
        w * 0.29,
        bottom - h * 0.06,
        w * 0.40,
        bottom - h * 0.05,
        cx,
        bottom,
      );
    final right = Path()
      ..moveTo(cx, top)
      ..cubicTo(
        w * 0.60,
        top - h * 0.05,
        w * 0.73,
        top - h * 0.04,
        w * 0.83,
        top + h * 0.02,
      )
      ..lineTo(w * 0.83, bottom)
      ..cubicTo(
        w * 0.71,
        bottom - h * 0.06,
        w * 0.60,
        bottom - h * 0.05,
        cx,
        bottom,
      );

    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
    canvas.drawLine(Offset(cx, top), Offset(cx, bottom), paint);
  }

  void _paintHearts(Canvas canvas, Size size, Paint paint) {
    canvas.drawPath(
      _heartPath(
          Offset(size.width * 0.42, size.height * 0.42), size.width * 0.46),
      paint,
    );
    canvas.drawPath(
      _heartPath(
          Offset(size.width * 0.66, size.height * 0.60), size.width * 0.32),
      paint,
    );
  }

  Path _heartPath(Offset center, double size) {
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    path.moveTo(x, y + size * 0.32);
    path.cubicTo(
      x - size * 0.08,
      y + size * 0.12,
      x - size * 0.52,
      y - size * 0.02,
      x - size * 0.52,
      y - size * 0.28,
    );
    path.cubicTo(
      x - size * 0.52,
      y - size * 0.52,
      x - size * 0.14,
      y - size * 0.52,
      x,
      y - size * 0.28,
    );
    path.cubicTo(
      x + size * 0.14,
      y - size * 0.52,
      x + size * 0.52,
      y - size * 0.52,
      x + size * 0.52,
      y - size * 0.28,
    );
    path.cubicTo(
      x + size * 0.52,
      y - size * 0.02,
      x + size * 0.08,
      y + size * 0.12,
      x,
      y + size * 0.32,
    );
    path.close();
    return path;
  }

  void _paintPerson(Canvas canvas, Size size, Paint paint) {
    final cx = size.width / 2;
    final headCenter = Offset(cx, size.height * 0.49);
    final headRadius = size.width * 0.12;
    final rayPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth * 0.58
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    _paintRays(
      canvas,
      headCenter,
      rayPaint,
      count: 7,
      inner: size.height * 0.22,
      outer: size.height * 0.40,
      startAngle: -math.pi,
      sweep: math.pi,
    );

    canvas.drawCircle(headCenter, headRadius, paint);

    final shoulders = Path()
      ..moveTo(size.width * 0.18, size.height * 0.88)
      ..cubicTo(
        size.width * 0.19,
        size.height * 0.69,
        size.width * 0.31,
        size.height * 0.62,
        cx,
        size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.69,
        size.height * 0.62,
        size.width * 0.81,
        size.height * 0.69,
        size.width * 0.82,
        size.height * 0.88,
      )
      ..lineTo(size.width * 0.18, size.height * 0.88);
    canvas.drawPath(shoulders, paint);
  }

  void _paintLotus(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final centerPetal = Path()
      ..moveTo(cx, h * 0.80)
      ..cubicTo(w * 0.39, h * 0.62, w * 0.41, h * 0.40, cx, h * 0.23)
      ..cubicTo(w * 0.59, h * 0.40, w * 0.61, h * 0.62, cx, h * 0.80);

    final leftInnerPetal = Path()
      ..moveTo(w * 0.48, h * 0.81)
      ..cubicTo(w * 0.34, h * 0.74, w * 0.26, h * 0.57, w * 0.28, h * 0.38)
      ..cubicTo(w * 0.43, h * 0.46, w * 0.51, h * 0.62, w * 0.48, h * 0.81);

    final rightInnerPetal = Path()
      ..moveTo(w * 0.52, h * 0.81)
      ..cubicTo(w * 0.66, h * 0.74, w * 0.74, h * 0.57, w * 0.72, h * 0.38)
      ..cubicTo(w * 0.57, h * 0.46, w * 0.49, h * 0.62, w * 0.52, h * 0.81);

    final leftOuterPetal = Path()
      ..moveTo(w * 0.47, h * 0.84)
      ..cubicTo(w * 0.27, h * 0.84, w * 0.13, h * 0.69, w * 0.12, h * 0.49)
      ..cubicTo(w * 0.31, h * 0.50, w * 0.43, h * 0.64, w * 0.47, h * 0.84);

    final rightOuterPetal = Path()
      ..moveTo(w * 0.53, h * 0.84)
      ..cubicTo(w * 0.73, h * 0.84, w * 0.87, h * 0.69, w * 0.88, h * 0.49)
      ..cubicTo(w * 0.69, h * 0.50, w * 0.57, h * 0.64, w * 0.53, h * 0.84);

    canvas
      ..drawPath(leftOuterPetal, paint)
      ..drawPath(rightOuterPetal, paint)
      ..drawPath(leftInnerPetal, paint)
      ..drawPath(rightInnerPetal, paint)
      ..drawPath(centerPetal, paint)
      ..drawArc(
        Rect.fromLTRB(w * 0.19, h * 0.69, w * 0.81, h * 0.92),
        0,
        math.pi,
        false,
        paint,
      );
  }

  void _paintWisdom(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final bubble = Path()
      ..moveTo(w * 0.50, h * 0.10)
      ..cubicTo(w * 0.73, h * 0.10, w * 0.89, h * 0.26, w * 0.89, h * 0.49)
      ..cubicTo(w * 0.89, h * 0.72, w * 0.72, h * 0.87, w * 0.49, h * 0.87)
      ..cubicTo(w * 0.42, h * 0.87, w * 0.36, h * 0.86, w * 0.31, h * 0.83)
      ..lineTo(w * 0.14, h * 0.92)
      ..lineTo(w * 0.18, h * 0.72)
      ..cubicTo(w * 0.13, h * 0.65, w * 0.11, h * 0.57, w * 0.11, h * 0.49)
      ..cubicTo(w * 0.11, h * 0.26, w * 0.27, h * 0.10, w * 0.50, h * 0.10)
      ..close();
    canvas.drawPath(bubble, paint);

    final sparkle = Path()
      ..moveTo(w * 0.50, h * 0.36)
      ..cubicTo(w * 0.51, h * 0.44, w * 0.54, h * 0.48, w * 0.61, h * 0.49)
      ..cubicTo(w * 0.54, h * 0.50, w * 0.51, h * 0.54, w * 0.50, h * 0.62)
      ..cubicTo(w * 0.49, h * 0.54, w * 0.46, h * 0.50, w * 0.39, h * 0.49)
      ..cubicTo(w * 0.46, h * 0.48, w * 0.49, h * 0.44, w * 0.50, h * 0.36)
      ..close();
    canvas.drawPath(sparkle, paint);

    canvas
      ..drawLine(Offset(w * 0.50, h * 0.20), Offset(w * 0.50, h * 0.25), paint)
      ..drawLine(Offset(w * 0.50, h * 0.73), Offset(w * 0.50, h * 0.78), paint)
      ..drawLine(Offset(w * 0.22, h * 0.49), Offset(w * 0.27, h * 0.49), paint)
      ..drawLine(Offset(w * 0.73, h * 0.49), Offset(w * 0.78, h * 0.49), paint);
  }

  @override
  bool shouldRepaint(covariant _HubGlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph;
}

class _HubBackgroundPainter extends CustomPainter {
  const _HubBackgroundPainter(this.glyph);

  final LibraryHubGlyph glyph;

  @override
  void paint(Canvas canvas, Size size) {
    final soft = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final softer = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (glyph) {
      case LibraryHubGlyph.dialogues:
        canvas.drawCircle(
          Offset(size.width * 0.52, size.height * 0.39),
          size.width * 0.36,
          soft,
        );
        _paintCornerArcs(canvas, size, softer);
      case LibraryHubGlyph.heartToHeart:
        canvas.drawCircle(
          Offset(size.width * 0.55, size.height * 0.40),
          size.width * 0.34,
          soft,
        );
        _paintWaves(canvas, size, soft, startY: 0.82);
      case LibraryHubGlyph.dadiJanki:
        canvas.drawCircle(
          Offset(size.width * 0.47, size.height * 0.39),
          size.width * 0.37,
          soft,
        );
        _paintLotusShadow(
          canvas,
          size,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.075)
            ..style = PaintingStyle.fill,
        );
      case LibraryHubGlyph.meditations:
        canvas.drawCircle(
          Offset(size.width * 0.50, size.height * 0.35),
          size.width * 0.35,
          soft,
        );
        _paintWaves(
          canvas,
          size,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.12)
            ..style = PaintingStyle.fill,
          startY: 0.73,
          secondAlpha: 0.075,
        );
      case LibraryHubGlyph.wordsOfWisdom:
        canvas.drawCircle(
          Offset(size.width * 0.22, size.height * 0.35),
          size.height * 0.34,
          soft,
        );
        _paintWaves(canvas, size, softer, startY: 0.72);
    }
  }

  void _paintCornerArcs(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromCircle(
      center: Offset(size.width * 0.12, size.height * 1.03),
      radius: size.width * 0.55,
    );
    final stroke = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16;
    canvas.drawArc(rect, math.pi * 1.25, math.pi * 0.62, false, stroke);
    canvas.drawArc(
      rect.deflate(size.width * 0.20),
      math.pi * 1.20,
      math.pi * 0.70,
      false,
      stroke..strokeWidth = size.width * 0.10,
    );
  }

  void _paintWaves(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double startY,
    double secondAlpha = 0.035,
  }) {
    final first = Path()
      ..moveTo(0, size.height * startY)
      ..cubicTo(
        size.width * 0.25,
        size.height * (startY - 0.14),
        size.width * 0.42,
        size.height * (startY + 0.12),
        size.width * 0.68,
        size.height * (startY - 0.04),
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * (startY - 0.13),
        size.width * 0.92,
        size.height * (startY - 0.12),
        size.width,
        size.height * (startY - 0.08),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(first, paint);

    final second = Path()
      ..moveTo(0, size.height * (startY + 0.12))
      ..cubicTo(
        size.width * 0.26,
        size.height * (startY - 0.02),
        size.width * 0.50,
        size.height * (startY + 0.19),
        size.width * 0.75,
        size.height * (startY + 0.02),
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * (startY - 0.05),
        size.width * 0.95,
        size.height * (startY - 0.02),
        size.width,
        size.height * startY,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      second,
      Paint()
        ..color = Colors.white.withValues(alpha: secondAlpha)
        ..style = PaintingStyle.fill,
    );
  }

  void _paintLotusShadow(Canvas canvas, Size size, Paint paint) {
    final origin = Offset(size.width * 0.66, size.height * 1.04);
    for (final angle in const [-1.0, -0.5, 0.0, 0.5, 1.0]) {
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -size.height * 0.17),
          width: size.width * 0.20,
          height: size.height * 0.40,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HubBackgroundPainter oldDelegate) =>
      oldDelegate.glyph != glyph;
}
