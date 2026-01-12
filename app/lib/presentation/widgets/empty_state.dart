import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Empty state widget when no articles exist
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral100, width: 1),
              ),
              child: const Center(
                child: Text(
                  '📚',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'まだ記事がないよ',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              '右下の＋ボタンから\n読みたい記事を追加してね！',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Hint card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral100, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      '他のアプリから「共有」でも\n追加できるよ！',
                      style: GoogleFonts.instrumentSans(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}