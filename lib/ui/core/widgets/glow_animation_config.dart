import 'package:flutter/material.dart';

/// Native meditation-glow options stored on `animation_url` as query params.
class GlowAnimationConfig {
  const GlowAnimationConfig({
    this.color = defaultColor,
    this.centerColor = defaultCenterColor,
    this.speed = defaultSpeed,
    this.size = defaultSize,
    this.intensity = defaultIntensity,
  });

  static const schemeUrl = 'native://glow';
  static const defaultColor = '7C52A0';
  static const defaultCenterColor = 'FFFFFF';
  static const defaultSpeed = 'slow';
  static const defaultSize = 'medium';
  static const defaultIntensity = 'soft';

  static const speedOptions = ['slow', 'medium', 'fast'];
  static const sizeOptions = ['small', 'medium', 'large'];
  static const intensityOptions = ['soft', 'medium', 'strong'];

  final String color;
  final String centerColor;
  final String speed;
  final String size;
  final String intensity;

  static GlowAnimationConfig parse(String? url) {
    if (url == null || !url.startsWith(schemeUrl)) {
      return const GlowAnimationConfig();
    }
    final uri = Uri.tryParse(url);
    final params = uri?.queryParameters ?? const <String, String>{};
    return GlowAnimationConfig(
      color: _normalizeHex(params['color'] ?? defaultColor),
      centerColor: _normalizeHex(
        params['center'] ?? defaultCenterColor,
        fallback: defaultCenterColor,
      ),
      speed: speedOptions.contains(params['speed'])
          ? params['speed']!
          : defaultSpeed,
      size: sizeOptions.contains(params['size'])
          ? params['size']!
          : defaultSize,
      intensity: intensityOptions.contains(params['intensity'])
          ? params['intensity']!
          : defaultIntensity,
    );
  }

  Color get midColor => _colorFromHex(color);
  Color get highlightColor => _colorFromHex(centerColor);

  Duration get duration {
    switch (speed) {
      case 'fast':
        return const Duration(milliseconds: 8000);
      case 'medium':
        return const Duration(milliseconds: 12000);
      default:
        return const Duration(milliseconds: 16000);
    }
  }

  double get minRadius {
    switch (size) {
      case 'small':
        return 0.06;
      case 'large':
        return 0.10;
      default:
        return 0.08;
    }
  }

  double get maxRadius {
    switch (size) {
      case 'small':
        return 0.32;
      case 'large':
        return 0.62;
      default:
        return 0.46;
    }
  }

  double get intensityScale {
    switch (intensity) {
      case 'strong':
        return 1.9;
      case 'medium':
        return 1.45;
      default:
        return 1.0;
    }
  }

  static String _normalizeHex(String raw, {String fallback = defaultColor}) {
    final hex = raw.replaceFirst('#', '').toUpperCase();
    if (hex.length == 6 && RegExp(r'^[0-9A-F]{6}$').hasMatch(hex)) {
      return hex;
    }
    return fallback;
  }

  static Color _colorFromHex(String hex) {
    return Color(int.parse('FF${_normalizeHex(hex)}', radix: 16));
  }
}
