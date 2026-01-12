import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sleek.design inspired color palette for Yommy
class AppColors {
  // Primary text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9B9B9B);

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color neutral50 = Color(0xFFF8F8F8);
  static const Color neutral100 = Color(0xFFE8E8E8);
  static const Color neutral200 = Color(0xFFD1D1D1);
  static const Color neutral300 = Color(0xFFB4B4B4);

  // Accent colors
  static const Color accent = Color(0xFFFFB84D); // Warm yellow/orange
  static const Color unreadAccent = Color(0xFF5B8DEE); // Soft blue
  static const Color readAccent = Color(0xFF6ECF9E); // Soft green

  // Status colors
  static const Color success = Color(0xFF6ECF9E);
  static const Color warning = Color(0xFFFFB84D);
  static const Color error = Color(0xFFEF5B5B);
}

/// App-wide theme configuration
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.unreadAccent,
        tertiary: AppColors.readAccent,
        surface: AppColors.backgroundWhite,
        error: AppColors.error,
      ),
      
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.backgroundWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neutral100, width: 1),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textTheme: TextTheme(
        // Display styles (DM Serif Display)
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        
        // Headline styles (DM Serif Display)
        headlineLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        
        // Title styles (Instrument Sans)
        titleLarge: GoogleFonts.instrumentSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.instrumentSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        
        // Body styles (Instrument Sans)
        bodyLarge: GoogleFonts.instrumentSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.instrumentSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        
        // Label styles (Instrument Sans)
        labelLarge: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.instrumentSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.instrumentSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}