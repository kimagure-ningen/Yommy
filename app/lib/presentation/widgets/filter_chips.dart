import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

/// Filter chips for article list
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(articleFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: '全て',
            isSelected: currentFilter == ArticleFilter.all,
            onTap: () =>
                ref.read(articleFilterProvider.notifier).state = ArticleFilter.all,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '未読',
            isSelected: currentFilter == ArticleFilter.unread,
            onTap: () =>
                ref.read(articleFilterProvider.notifier).state = ArticleFilter.unread,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '読了',
            isSelected: currentFilter == ArticleFilter.read,
            onTap: () =>
                ref.read(articleFilterProvider.notifier).state = ArticleFilter.read,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
