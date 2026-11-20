import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Plays once over [child]. Confetti and sparkle are painted on top and do
/// not block taps. Pulse scales the child in.
class AppPopupCelebration extends StatefulWidget {
  const AppPopupCelebration({
    super.key,
    required this.animation,
    required this.child,
    this.playId = 0,
  });

  final String animation;
  final Widget child;
  final int playId;

  @override
  State<AppPopupCelebration> createState() => _AppPopupCelebrationState();
}

class _AppPopupCelebrationState extends State<AppPopupCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_Piece> _pieces = const [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _duration(widget.animation));
    _prepare(widget.animation, widget.playId);
  }

  @override
  void didUpdateWidget(AppPopupCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation == widget.animation &&
        oldWidget.playId == widget.playId) {
      return;
    }
    _controller.duration = _duration(widget.animation);
    _prepare(widget.animation, widget.playId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prepare(String animation, int playId) {
    _pieces = _makePieces(animation, playId);
    if (animation == 'none') {
      _controller.value = 0;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animation == 'none') return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final scale = widget.animation == 'pulse'
            ? 0.94 + 0.06 * Curves.elasticOut.transform(progress)
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: Stack(
            children: [
              child!,
              if (widget.animation == 'confetti' ||
                  widget.animation == 'sparkle')
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _BurstPainter(
                        progress: progress,
                        pieces: _pieces,
                        sparkle: widget.animation == 'sparkle',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

Duration _duration(String animation) {
  switch (animation) {
    case 'sparkle':
      return const Duration(milliseconds: 1700);
    case 'pulse':
      return const Duration(milliseconds: 900);
    default:
      return const Duration(milliseconds: 2600);
  }
}

const _palette = <Color>[
  Color(0xFF7C52A0),
  Color(0xFFFCC612),
  Color(0xFFD66853),
  Color(0xFFFFD971),
  Color(0xFF39D2C0),
  Color(0xFFB9A0CB),
];

class _Piece {
  const _Piece({
    required this.x,
    required this.y,
    required this.delay,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  final double x;
  final double y;
  final double delay;
  final double drift;
  final double spin;
  final double size;
  final Color color;
  final bool round;
}

List<_Piece> _makePieces(String animation, int seed) {
  if (animation != 'confetti' && animation != 'sparkle') return const [];
  final random = math.Random(seed + animation.hashCode);
  final count = animation == 'sparkle' ? 14 : 48;
  return [
    for (var index = 0; index < count; index++)
      _Piece(
        x: random.nextDouble(),
        y: animation == 'sparkle'
            ? 0.06 + random.nextDouble() * 0.42
            : random.nextDouble(),
        delay: random.nextDouble() * 0.18,
        drift: 0.03 + random.nextDouble() * 0.07,
        spin: 2 + random.nextDouble() * 6,
        size: animation == 'sparkle'
            ? 7 + random.nextDouble() * 8
            : 6 + random.nextDouble() * 7,
        color: _palette[random.nextInt(_palette.length)],
        round: random.nextBool(),
      ),
  ];
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({
    required this.progress,
    required this.pieces,
    required this.sparkle,
  });

  final double progress;
  final List<_Piece> pieces;
  final bool sparkle;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress <= 0) return;
    final paint = Paint();
    for (final piece in pieces) {
      final span = 1 - piece.delay;
      final local = ((progress - piece.delay) / span).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final opacity = sparkle ? math.sin(local * math.pi) : _fallOpacity(local);
      if (opacity <= 0) continue;
      paint.color = piece.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      if (sparkle) {
        final center = Offset(piece.x * size.width, piece.y * size.height);
        _star(canvas, center, piece.size * opacity, paint);
        continue;
      }
      final y = (-0.12 + local * 1.2) * size.height;
      final x =
          (piece.x + math.sin(local * piece.spin) * piece.drift) * size.width;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * piece.spin);
      if (piece.round) {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero,
                width: piece.size,
                height: piece.size * 0.55),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  double _fallOpacity(double local) {
    if (local < 0.12) return local / 0.12;
    if (local > 0.78) return (1 - local) / 0.22;
    return 1;
  }

  void _star(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var point = 0; point < 8; point++) {
      final distance = point.isEven ? radius : radius * 0.38;
      final angle = -math.pi / 2 + point * math.pi / 4;
      final offset = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.sparkle != sparkle;
  }
}
