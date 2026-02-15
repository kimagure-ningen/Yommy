import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/article.dart';
import '../data/models/reminder_settings.dart';
import '../data/repositories/article_repository.dart';

/// Service for managing local notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone and set to device's local timezone
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to article list or specific article
    // This will be handled in Phase 3
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iOS != null) {
      final result = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final result = await android.requestNotificationsPermission();
      return result ?? false;
    }

    return true;
  }

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder({
    required ReminderSettings settings,
    required List<Article> articlesToRemind,
  }) async {
    // Cancel existing reminders first
    await cancelAllReminders();

    if (!settings.enabled || articlesToRemind.isEmpty) return;

    // Build notification content
    final title = 'Yommy 📚';
    final body = _buildNotificationBody(articlesToRemind);

    // Schedule for each active day
    for (final day in settings.activeDays) {
      await _scheduleWeeklyNotification(
        id: day, // Use day as ID for uniqueness
        title: title,
        body: body,
        hour: settings.hour,
        minute: settings.minute,
        dayOfWeek: day + 1, // flutter_local_notifications uses 1-7 (Mon-Sun)
      );
    }
  }

  /// Build notification body text
  String _buildNotificationBody(List<Article> articles) {
    if (articles.isEmpty) {
      return '今日は読むものがないよ！';
    }

    if (articles.length == 1) {
      return '「${_truncate(articles.first.title, 30)}」を読んでみよう！';
    }

    final titles = articles
        .take(2)
        .map((a) => '「${_truncate(a.title, 15)}」')
        .join('、');
    
    if (articles.length > 2) {
      return '$titles など${articles.length}件の記事があるよ！';
    }
    
    return '$titles を読んでみよう！';
  }

  /// Truncate text with ellipsis
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Schedule a weekly notification
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Find next occurrence of this day of week
    while (scheduledDate.weekday != dayOfWeek ||
        scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'yommy_reminders',
          'Reading Reminders',
          channelDescription: 'Daily reading reminders from Yommy',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    // Ensure permissions are granted before showing notification
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('通知の許可が必要です。設定アプリから通知を許可してください。');
    }

    await _notifications.show(
      999,
      'Yommy 📚',
      'テスト通知だよ！設定完了！',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'yommy_reminders',
          'Reading Reminders',
          channelDescription: 'Daily reading reminders from Yommy',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Schedule reminders based on current settings and articles
  /// This is the main entry point for scheduling - it reads settings,
  /// selects articles based on mode, and schedules notifications.
  Future<void> scheduleRemindersFromSettings({
    required ReminderSettings settings,
    required ArticleRepository articleRepository,
  }) async {
    // Cancel existing reminders first
    await cancelAllReminders();

    // Don't schedule if disabled or no active days
    if (!settings.enabled || settings.activeDays.isEmpty) return;

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    // Select articles based on mode
    List<Article> articles;
    switch (settings.mode) {
      case ReminderMode.random:
        articles = articleRepository.getRandomUnread(settings.articleCount);
        break;
      case ReminderMode.oldest:
        articles = articleRepository.getOldestUnread(settings.articleCount);
        break;
      case ReminderMode.newest:
        articles = articleRepository.getNewestUnread(settings.articleCount);
        break;
    }

    // Schedule the reminder with selected articles
    await scheduleDailyReminder(
      settings: settings,
      articlesToRemind: articles,
    );
  }
}
