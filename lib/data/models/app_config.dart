/// Application configuration model
/// Used to control mobile app features via admin settings
class AppConfig {
  final bool enableJourneyList;
  final bool enableCommunityModule;

  AppConfig({
    required this.enableJourneyList,
    required this.enableCommunityModule,
  });

  /// Create default configuration (all features enabled)
  factory AppConfig.defaults() {
    return AppConfig(
      enableJourneyList: true,
      enableCommunityModule: true,
    );
  }

  /// Create configuration from settings map
  /// Settings map comes from SettingsRepository.getSettingsByCategory('mobile_features')
  factory AppConfig.fromMap(Map<String, String> settings) {
    return AppConfig(
      enableJourneyList: _parseBool(settings['enable_journey_list'], true),
      enableCommunityModule: _parseBool(settings['enable_community_module'], true),
    );
  }

  /// Parse string to boolean with default value
  static bool _parseBool(String? value, bool defaultValue) {
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Copy with method for creating modified copies
  AppConfig copyWith({
    bool? enableJourneyList,
    bool? enableCommunityModule,
  }) {
    return AppConfig(
      enableJourneyList: enableJourneyList ?? this.enableJourneyList,
      enableCommunityModule: enableCommunityModule ?? this.enableCommunityModule,
    );
  }

  @override
  String toString() {
    return 'AppConfig(enableJourneyList: $enableJourneyList, enableCommunityModule: $enableCommunityModule)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppConfig &&
        other.enableJourneyList == enableJourneyList &&
        other.enableCommunityModule == enableCommunityModule;
  }

  @override
  int get hashCode => enableJourneyList.hashCode ^ enableCommunityModule.hashCode;
}
