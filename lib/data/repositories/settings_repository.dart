import 'package:gw_community/data/services/supabase/database/tables/cc_settings.dart';

/// Repository for managing application settings
class SettingsRepository {
  /// Fetch a specific setting value by key
  Future<String?> getSettingValue(String key) async {
    try {
      final result = await CcSettingsTable().querySingleRow(
        queryFn: (q) => q.eq('setting_key', key),
      );

      if (result.isEmpty) return null;
      return result.first.value;
    } catch (e) {
      // Graceful fallback on error
      return null;
    }
  }

  /// Fetch multiple settings by category
  Future<Map<String, String>> getSettingsByCategory(String category) async {
    try {
      final result = await CcSettingsTable().queryRows(
        queryFn: (q) => q.eq('category', category),
      );

      final Map<String, String> settings = {};
      for (final row in result) {
        if (row.settingKey != null && row.value != null) {
          settings[row.settingKey!] = row.value!;
        }
      }
      return settings;
    } catch (e) {
      // Return empty map on error
      return {};
    }
  }

  /// Get all settings (for debugging/admin purposes)
  Future<List<CcSettingsRow>> getAllSettings() async {
    try {
      final result = await CcSettingsTable().queryRows(
        queryFn: (q) => q.order('category').order('setting_key'),
      );
      return result;
    } catch (e) {
      return [];
    }
  }
}
