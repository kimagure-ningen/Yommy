import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sleek design system color palette
class AppColors {
  // Background & Foreground
  static const Color background = Color(0xFFF8FAFC);
  static const Color foreground = Color(0xFF0F172A);
  
  // Primary
  static const Color primary = Color(0xFF1E293B);
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  
  // Secondary
  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryLight = Color(0xFFF8FAFC);
  static const Color secondaryDark = Color(0xFFE2E8F0);
  static const Color secondaryForeground = Color(0xFF334155);
  
  // Muted
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  
  // Accent
  static const Color accent = Color(0xFFE0E7FF);
  static const Color accentForeground = Color(0xFF3730A3);
  
  // Destructive / Error
  static const Color destructive = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);
  
  // Card
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF0F172A);
  
  // Border
  static const Color border = Color(0xFFE2E8F0);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  
  // Badge colors
  static const Color unreadBadge = Color(0xFF3730A3);
  static const Color readBadge = Color(0xFF64748B);
}

/// App-wide theme configuration
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.primaryForeground,
        onSecondary: AppColors.secondaryForeground,
        onSurface: AppColors.foreground,
      ),
      
      scaffoldBackgroundColor: AppColors.background,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 8,
        shape: CircleBorder(),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.instrumentSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.instrumentSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        headlineMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        titleLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        titleMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        bodyLarge: GoogleFonts.instrumentSans(
          fontSize: 16,
          color: AppColors.foreground,
        ),
        bodyMedium: GoogleFonts.instrumentSans(
          fontSize: 14,
          color: AppColors.mutedForeground,
        ),
        bodySmall: GoogleFonts.instrumentSans(
          fontSize: 12,
          color: AppColors.mutedForeground,
        ),
        labelLarge: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        labelMedium: GoogleFonts.instrumentSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedForeground,
        ),
        labelSmall: GoogleFonts.instrumentSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return light;
  }
}