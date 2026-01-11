import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

/// Filter tabs for article list
class FilterChips extends ConsumerStatefulWidget {
  const FilterChips({super.key});

  @override
  ConsumerState<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends ConsumerState<FilterChips> {
  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(articleFilterProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'All',
              filter: ArticleFilter.all,
              isSelected: currentFilter == ArticleFilter.all,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Unread',
              filter: ArticleFilter.unread,
              isSelected: currentFilter == ArticleFilter.unread,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Read',
              filter: ArticleFilter.read,
              isSelected: currentFilter == ArticleFilter.read,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required ArticleFilter filter,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(articleFilterProvider.notifier).state = filter;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? AppColors.foreground
                  : AppColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}