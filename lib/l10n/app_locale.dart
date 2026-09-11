import 'package:flutter/material.dart';

/// Supported UI languages. A journey may lock labels to its own language.
class AppLocale {
  static const en = Locale('en');
  static const pt = Locale('pt');

  static const supported = [en, pt];

  static Locale parse(String? code) {
    final normalized = (code ?? '').toLowerCase().split(RegExp('[-_]')).first;
    return normalized == 'pt' ? pt : en;
  }

  /// Follows the phone language when the user has not chosen one yet.
  static Locale resolve({
    required Locale? stored,
    required Locale? device,
  }) {
    if (stored != null) return parse(stored.languageCode);
    if (device != null && device.languageCode == 'pt') return pt;
    return en;
  }
}
