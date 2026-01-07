import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/article.dart';
import 'data/models/reminder_settings.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (local database)
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(ArticleStatusAdapter());
  Hive.registerAdapter(ReminderSettingsAdapter());
  Hive.registerAdapter(ReminderModeAdapter());

  await Hive.openBox<Article>('articles');
  await Hive.openBox<ReminderSettings>('settings');

  // Initialize notifications
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: YommyApp(),
    ),
  );
}
