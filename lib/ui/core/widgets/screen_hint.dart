import 'package:flutter/material.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifies all active ScreenHint instances to re-check their seen state.
/// Call [resetAll] after clearing SharedPreferences keys.
class HintResetNotifier extends ChangeNotifier {
  static final instance = HintResetNotifier._();
  HintResetNotifier._();

  void resetAll() => notifyListeners();
}

/// Shows a one-time speech-bubble hint above the bottom nav bar.
/// [pointerFraction] (0.0–1.0) is the fraction of the SCREEN width where
/// the pointer tip should point — typically the center of the nav icon.
class ScreenHint extends StatefulWidget {
  const ScreenHint({
    super.key,
    required this.hintKey,
    required this.title,
    required this.message,
    required this.child,
    this.pointerFraction = 0.5,
  });

  final String hintKey;
  final String title;
  final String message;
  final Widget child;

  /// Fraction (0–1) of screen width where the arrow tip points.
  /// E.g. 0.3 = Library icon, 0.5 = Journey icon, 0.7 = Community icon.
  final double pointerFraction;

  @override
  State<ScreenHint> createState() => _ScreenHintState();
}

class _ScreenHintState extends State<ScreenHint> with SingleTickerProviderStateMixin {
  static const double _balloonMargin = 16.0;
  static const double _pointerHeight = 14.0;

  bool _visible = false;
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _checkAndShow();
    HintResetNotifier.instance.addListener(_onReset);
  }

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(widget.hintKey) ?? false;
    if (seen || !mounted) return;

    await prefs.setBool(widget.hintKey, true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _visible = true);
    _controller.forward();

    await Future.delayed(const Duration(seconds: 12));
    if (!mounted) return;

    _dismiss();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) setState(() => _visible = false);
  }

  Future<void> _onReset() async {
    if (_visible) {
      _controller.reverse();
      if (mounted) setState(() => _visible = false);
    }
    _checkAndShow();
  }

  @override
  void dispose() {
    HintResetNotifier.instance.removeListener(_onReset);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_visible) {
      // Convert screen-relative fraction to balloon-relative fraction.
      final screenWidth = MediaQuery.of(context).size.width;
      final balloonWidth = screenWidth - _balloonMargin * 2;
      final balloonPointerFraction =
          ((screenWidth * widget.pointerFraction) - _balloonMargin) / balloonWidth;

      return SizedBox.expand(
        child: Stack(
          children: [
            widget.child,
            Positioned(
              left: _balloonMargin,
              right: _balloonMargin,
              bottom: 0,
              child: FadeTransition(
                opacity: _opacity,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: CustomPaint(
                    painter: _SpeechBubblePainter(
                      color: AppTheme.of(context).primary,
                      pointerFraction: balloonPointerFraction,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16 + _pointerHeight),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.message,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismiss,
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.expand(
      child: Stack(
        children: [widget.child],
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color color;
  final double pointerFraction;

  static const double _pointerH = 14.0;
  static const double _pointerHalfW = 12.0;
  static const double _r = 16.0;

  const _SpeechBubblePainter({
    required this.color,
    this.pointerFraction = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    // Native elevation shadow
    canvas.drawShadow(path, Colors.black, 8, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  Path _buildPath(Size size) {
    final bodyH = size.height - _pointerH;
    // Clamp pointer so tip stays inside the rounded corners
    final px = (size.width * pointerFraction).clamp(_pointerHalfW + _r, size.width - _pointerHalfW - _r);

    return Path()
      ..moveTo(_r, 0)
      ..lineTo(size.width - _r, 0)
      ..arcToPoint(Offset(size.width, _r), radius: const Radius.circular(_r))
      ..lineTo(size.width, bodyH - _r)
      ..arcToPoint(Offset(size.width - _r, bodyH), radius: const Radius.circular(_r))
      ..lineTo(px + _pointerHalfW, bodyH)
      ..lineTo(px, size.height)          // tip of the arrow
      ..lineTo(px - _pointerHalfW, bodyH)
      ..lineTo(_r, bodyH)
      ..arcToPoint(Offset(0, bodyH - _r), radius: const Radius.circular(_r))
      ..lineTo(0, _r)
      ..arcToPoint(Offset(_r, 0), radius: const Radius.circular(_r))
      ..close();
  }

  @override
  bool shouldRepaint(_SpeechBubblePainter old) =>
      color != old.color || pointerFraction != old.pointerFraction;
}
