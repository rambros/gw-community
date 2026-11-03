/// Application configuration model
/// Used to control mobile app features via admin settings
class AppConfig {
  final bool enableJourneyList;
  final bool enableCommunityModule;
  final bool enableEditName;

  AppConfig({
    required this.enableJourneyList,
    required this.enableCommunityModule,
    required this.enableEditName,
  });

  /// Create default configuration.
  /// Journey list and community stay on. Name editing stays off until
  /// the admin enables "Enable edit Name".
  factory AppConfig.defaults() {
    return AppConfig(
      enableJourneyList: true,
      enableCommunityModule: true,
      enableEditName: false,
    );
  }

  /// Create configuration from settings map
  /// Settings map comes from SettingsRepository.getSettingsByCategory('mobile_features')
  factory AppConfig.fromMap(Map<String, String> settings) {
    return AppConfig(
      enableJourneyList: _parseBool(settings['enable_journey_list'], true),
      enableCommunityModule: _parseBool(settings['enable_community_module'], true),
      enableEditName: _parseBool(settings['enable_edit_name'], false),
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
    bool? enableEditName,
  }) {
    return AppConfig(
      enableJourneyList: enableJourneyList ?? this.enableJourneyList,
      enableCommunityModule: enableCommunityModule ?? this.enableCommunityModule,
      enableEditName: enableEditName ?? this.enableEditName,
    );
  }

  @override
  String toString() {
    return 'AppConfig(enableJourneyList: $enableJourneyList, enableCommunityModule: $enableCommunityModule, enableEditName: $enableEditName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppConfig &&
        other.enableJourneyList == enableJourneyList &&
        other.enableCommunityModule == enableCommunityModule &&
        other.enableEditName == enableEditName;
  }

  @override
  int get hashCode =>
      enableJourneyList.hashCode ^
      enableCommunityModule.hashCode ^
      enableEditName.hashCode;
}
