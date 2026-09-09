/// Setting keys and fallback for bilingual community guidelines.
class GuidelinesLocale {
  static const englishKey = 'community_guidelines';
  static const portugueseKey = 'community_guidelines_pt';

  /// Prefers Portuguese when the UI is in Portuguese, otherwise English.
  /// Falls back to the other language if the preferred one is empty.
  static String? pick({
    required String languageCode,
    String? english,
    String? portuguese,
  }) {
    final en = _orNull(english);
    final pt = _orNull(portuguese);
    final wantsPortuguese = languageCode.toLowerCase().startsWith('pt');
    if (wantsPortuguese) return pt ?? en;
    return en ?? pt;
  }

  static String? _orNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return value;
  }
}

class CommunityGuidelinesVersions {
  const CommunityGuidelinesVersions({
    this.english,
    this.portuguese,
  });

  final String? english;
  final String? portuguese;

  String? resolve(String languageCode) => GuidelinesLocale.pick(
        languageCode: languageCode,
        english: english,
        portuguese: portuguese,
      );
}
