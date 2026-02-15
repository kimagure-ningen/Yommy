import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../app.dart';
import '../data/models/article.dart';
import '../data/models/reminder_settings.dart';
import '../data/repositories/article_repository.dart';
import '../presentation/screens/article_detail_screen.dart';

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
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

  /// Handle notification tap — navigate to article detail
  void _onNotificationTapped(NotificationResponse response) {
    final articleId = response.payload;
    if (articleId == null || articleId.isEmpty) return;

    // Look up the article from Hive
    final articleRepo = ArticleRepository();
    final article = articleRepo.getById(articleId);
    if (article == null) return;

    // Navigate to article detail screen using global navigator key
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
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

  /// Schedule reminders based on current settings and articles.
  /// This is the main entry point — selects articles by mode and schedules.
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

    // Select a single article based on mode
    List<Article> candidates;
    switch (settings.mode) {
      case ReminderMode.random:
        candidates = articleRepository.getRandomUnread(1);
        break;
      case ReminderMode.oldest:
        candidates = articleRepository.getOldestUnread(1);
        break;
      case ReminderMode.newest:
        candidates = articleRepository.getNewestUnread(1);
        break;
    }

    if (candidates.isEmpty) return;

    final article = candidates.first;

    // Build notification content
    final title = 'Yommy 📚';
    final body = _buildNotificationBody(article, settings.mode);

    // Schedule for each active day
    for (final day in settings.activeDays) {
      await _scheduleWeeklyNotification(
        id: day, // Use day as ID for uniqueness
        title: title,
        body: body,
        hour: settings.hour,
        minute: settings.minute,
        dayOfWeek: day + 1, // flutter_local_notifications uses 1-7 (Mon-Sun)
        payload: article.id,
      );
    }
  }

  /// Build notification body based on article and mode
  String _buildNotificationBody(Article article, ReminderMode mode) {
    final truncatedTitle = _truncate(article.title, 30);

    switch (mode) {
      case ReminderMode.random:
        return '🎲 ランダムに選んだよ！「$truncatedTitle」を読もう！';
      case ReminderMode.oldest:
        return '📦 ずっと待ってる記事があるよ！「$truncatedTitle」を読もう！';
      case ReminderMode.newest:
        return '✨ 最新の記事だよ！「$truncatedTitle」を読もう！';
    }
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
    required String payload,
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
      payload: payload,
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
}
