import 'package:flutter/material.dart';

/// Loops opacity between [minOpacity] and [maxOpacity] for a breathing effect.
class PulsingOpacity extends StatefulWidget {
  const PulsingOpacity({
    super.key,
    required this.child,
    this.minOpacity = 0.4,
    this.maxOpacity = 1.0,
    this.duration = const Duration(milliseconds: 3200),
    this.curve = Curves.easeInOut,
  });

  final Widget child;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;
  final Curve curve;

  @override
  State<PulsingOpacity> createState() => _PulsingOpacityState();
}

class _PulsingOpacityState extends State<PulsingOpacity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(covariant PulsingOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity ||
        oldWidget.curve != widget.curve) {
      _opacity = Tween<double>(
        begin: widget.minOpacity,
        end: widget.maxOpacity,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
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
      animation: _opacity,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Where to apply the breathing pulse on inspiration/audio screens.
enum InspirationPulseStyle {
  /// Pulse only the central artwork (opacity fade).
  artwork,

  /// GIF-like radial glow on the full screen background.
  radialGlow,

  /// Radial glow plus a subtle opacity pulse on the artwork.
  both,
}
