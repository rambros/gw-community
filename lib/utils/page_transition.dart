import 'package:flutter/material.dart';

enum PageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
  leftToRightJoined,
  rightToLeftJoined,
}

class PageTransition<T> {
  final PageTransitionType type;
  final Duration duration;
  final Duration reverseDuration;
  final Alignment? alignment;
  final Widget child;

  PageTransition({
    required this.type,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.alignment,
  });

  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: animation, child: child);
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: animation,
          alignment: alignment ?? Alignment.center,
          child: child,
        );
      case PageTransitionType.rotate:
        return RotationTransition(
          turns: animation,
          alignment: alignment ?? Alignment.center,
          child: child,
        );
      case PageTransitionType.size:
        return SizeTransition(
          sizeFactor: animation,
          alignment: alignment ?? Alignment.center,
          child: child,
        );
      case PageTransitionType.rightToLeft:
      case PageTransitionType.rightToLeftWithFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: type == PageTransitionType.rightToLeftWithFade
              ? FadeTransition(opacity: animation, child: child)
              : child,
        );
      case PageTransitionType.leftToRight:
      case PageTransitionType.leftToRightWithFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: type == PageTransitionType.leftToRightWithFade
              ? FadeTransition(opacity: animation, child: child)
              : child,
        );
      case PageTransitionType.topToBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case PageTransitionType.bottomToTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      default:
        return FadeTransition(opacity: animation, child: child);
    }
  }
}
