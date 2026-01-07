import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

/// Yommy - A cute reading list app
class YommyApp extends StatelessWidget {
  const YommyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yommy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
