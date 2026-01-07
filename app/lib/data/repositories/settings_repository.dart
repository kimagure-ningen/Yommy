import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder_settings.dart';

/// Repository for managing app settings
class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _reminderKey = 'reminder';

  Box<ReminderSettings> get _box => Hive.box<ReminderSettings>(_boxName);

  /// Get reminder settings (creates defaults if not exists)
  ReminderSettings getReminderSettings() {
    final settings = _box.get(_reminderKey);
    if (settings == null) {
      final defaults = ReminderSettings.defaults;
      _box.put(_reminderKey, defaults);
      return defaults;
    }
    return settings;
  }

  /// Save reminder settings
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _box.put(_reminderKey, settings);
  }

  /// Update reminder settings with specific changes
  Future<ReminderSettings> updateReminderSettings({
    bool? enabled,
    int? hour,
    int? minute,
    ReminderMode? mode,
    int? articleCount,
    List<int>? activeDays,
  }) async {
    final current = getReminderSettings();
    final updated = current.copyWith(
      enabled: enabled,
      hour: hour,
      minute: minute,
      mode: mode,
      articleCount: articleCount,
      activeDays: activeDays,
    );
    await saveReminderSettings(updated);
    return updated;
  }

  /// Watch for settings changes
  Listenable watchSettings() => _box.listenable();
}
