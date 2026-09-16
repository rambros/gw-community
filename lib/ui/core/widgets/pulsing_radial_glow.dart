import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Steady intermediate glow with overlapping outward waves — no contraction.
class PulsingRadialGlow extends StatefulWidget {
  const PulsingRadialGlow({
    super.key,
    required this.highlightColor,
    required this.centerColor,
    required this.midColor,
    required this.outerColor,
    this.duration = const Duration(milliseconds: 16000),
    this.center = Alignment.center,
    this.waveCount = 4,
    this.minRadius = 0.08,
    this.maxRadius = 0.46,
    this.intensity = 1.0,
  });

  final Color highlightColor;
  final Color centerColor;
  final Color midColor;
  final Color outerColor;
  final Duration duration;
  final Alignment center;
  final int waveCount;
  /// Wave start, as a fraction of the shortest side.
  final double minRadius;
  /// Wave end, as a fraction of the shortest side.
  final double maxRadius;
  final double intensity;

  @override
  State<PulsingRadialGlow> createState() => _PulsingRadialGlowState();
}

class _PulsingRadialGlowState extends State<PulsingRadialGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant PulsingRadialGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _MeditationWavesPainter(
            progress: _controller.value,
            highlightColor: widget.highlightColor,
            centerColor: widget.centerColor,
            midColor: widget.midColor,
            outerColor: widget.outerColor,
            center: widget.center,
            waveCount: widget.waveCount.clamp(2, 6),
            minRadius: widget.minRadius,
            maxRadius: widget.maxRadius,
            intensity: widget.intensity,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _MeditationWavesPainter extends CustomPainter {
  _MeditationWavesPainter({
    required this.progress,
    required this.highlightColor,
    required this.centerColor,
    required this.midColor,
    required this.outerColor,
    required this.center,
    required this.waveCount,
    required this.minRadius,
    required this.maxRadius,
    required this.intensity,
  });

  final double progress;
  final Color highlightColor;
  final Color centerColor;
  final Color midColor;
  final Color outerColor;
  final Alignment center;
  final int waveCount;
  final double minRadius;
  final double maxRadius;
  final double intensity;

  Offset _origin(Size size) {
    return Offset(
      size.width * (0.5 + center.x / 2),
      size.height * (0.5 + center.y / 2),
    );
  }

  /// Soft appear at the center, soft disappear at the edge — no pop.
  double _envelope(double t) {
    if (t < 0.12) {
      return Curves.easeInOut.transform(t / 0.12);
    }
    if (t > 0.78) {
      return Curves.easeInOut.transform((1.0 - t) / 0.22);
    }
    return 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final origin = _origin(size);
    final shortest = math.min(size.width, size.height);
    final figureRadius = shortest * maxRadius;
    final i = intensity.clamp(0.6, 2.2);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            centerColor.withValues(alpha: (0.12 * i).clamp(0.0, 0.4)),
            midColor.withValues(alpha: (0.07 * i).clamp(0.0, 0.28)),
            outerColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(Rect.fromCircle(center: origin, radius: figureRadius)),
    );

    for (var iWave = 0; iWave < waveCount; iWave++) {
      final t = (progress + iWave / waveCount) % 1.0;
      final eased = Curves.easeOut.transform(t);
      final radius = shortest * (minRadius + (maxRadius - minRadius) * eased);
      final alpha = _envelope(t);
      if (alpha <= 0.01) continue;

      final band = shortest * 0.16;
      canvas.drawCircle(
        origin,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = band
          ..color = midColor.withValues(alpha: (0.11 * i * alpha).clamp(0.0, 0.35))
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 28),
      );
      canvas.drawCircle(
        origin,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = band * 0.45
          ..color = centerColor.withValues(
            alpha: (0.09 * i * alpha).clamp(0.0, 0.3),
          )
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 16),
      );
    }

    canvas.drawCircle(
      origin,
      shortest * 0.12,
      Paint()
        ..shader = RadialGradient(
          colors: [
            highlightColor.withValues(alpha: (0.28 * i).clamp(0.0, 0.55)),
            centerColor.withValues(alpha: (0.1 * i).clamp(0.0, 0.28)),
            outerColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: origin, radius: shortest * 0.12),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _MeditationWavesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.centerColor != centerColor ||
        oldDelegate.midColor != midColor ||
        oldDelegate.outerColor != outerColor ||
        oldDelegate.waveCount != waveCount ||
        oldDelegate.minRadius != minRadius ||
        oldDelegate.maxRadius != maxRadius ||
        oldDelegate.intensity != intensity;
  }
}
