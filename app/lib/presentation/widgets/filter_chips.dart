import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

/// Filter chips for article list
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(articleFilterProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral100, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: '全て',
              isSelected: currentFilter == ArticleFilter.all,
              onTap: () => ref.read(articleFilterProvider.notifier).state = ArticleFilter.all,
            ),
          ),
          Expanded(
            child: _FilterTab(
              label: '未読',
              isSelected: currentFilter == ArticleFilter.unread,
              onTap: () => ref.read(articleFilterProvider.notifier).state = ArticleFilter.unread,
            ),
          ),
          Expanded(
            child: _FilterTab(
              label: '読了',
              isSelected: currentFilter == ArticleFilter.read,
              onTap: () => ref.read(articleFilterProvider.notifier).state = ArticleFilter.read,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? AppColors.backgroundWhite : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}