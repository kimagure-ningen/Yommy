import 'package:hive/hive.dart';

part 'reminder_settings.g.dart';

/// How articles are selected for reminders
@HiveType(typeId: 3)
enum ReminderMode {
  /// Pick random unread articles
  @HiveField(0)
  random,

  /// Pick oldest unread articles first
  @HiveField(1)
  oldest,

  /// Pick newest unread articles first
  @HiveField(2)
  newest,
}

/// User's reminder preferences
@HiveType(typeId: 2)
class ReminderSettings extends HiveObject {
  /// Whether reminders are enabled
  @HiveField(0)
  bool enabled;

  /// Hour of the day to send reminder (0-23)
  @HiveField(1)
  int hour;

  /// Minute of the hour to send reminder (0-59)
  @HiveField(2)
  int minute;

  /// How articles are selected
  @HiveField(3)
  ReminderMode mode;

  /// Number of articles to show in each reminder
  @HiveField(4)
  int articleCount;

  /// Days of the week to send reminders (0=Monday, 6=Sunday)
  @HiveField(5)
  List<int> activeDays;

  ReminderSettings({
    this.enabled = true,
    this.hour = 9,
    this.minute = 0,
    this.mode = ReminderMode.random,
    this.articleCount = 3,
    List<int>? activeDays,
  }) : activeDays = activeDays ?? [0, 1, 2, 3, 4, 5, 6]; // All days by default

  /// Creates a copy with updated fields
  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    ReminderMode? mode,
    int? articleCount,
    List<int>? activeDays,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      mode: mode ?? this.mode,
      articleCount: articleCount ?? this.articleCount,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  /// Formatted time string (e.g., "09:00")
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Check if reminder should fire on a specific day
  bool isActiveOnDay(int day) => activeDays.contains(day);

  /// Human-readable mode description
  String get modeDescription {
    switch (mode) {
      case ReminderMode.random:
        return 'ランダム';
      case ReminderMode.oldest:
        return '古い順';
      case ReminderMode.newest:
        return '新しい順';
    }
  }

  /// Default settings
  static ReminderSettings get defaults => ReminderSettings();
}
