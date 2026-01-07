import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import 'add_article_screen.dart';
import 'settings_screen.dart';

/// Main home screen showing article list
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(filteredArticlesProvider);
    final counts = ref.watch(articleCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yommy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            const Text('📚', style: TextStyle(fontSize: 24)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          _buildStatsBar(context, counts),

          // Filter chips
          const FilterChips(),

          // Article list
          Expanded(
            child: articles.isEmpty
                ? const EmptyState()
                : _buildArticleList(context, ref, articles),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddArticle(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, ArticleCounts counts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            '全て',
            counts.total,
            AppColors.textSecondaryLight,
          ),
          _buildStatItem(
            context,
            '未読',
            counts.unread,
            AppColors.unreadBadge,
          ),
          _buildStatItem(
            context,
            '読了',
            counts.read,
            AppColors.readBadge,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildArticleList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> articles,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(articlesProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 100,
        ),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleCard(
            article: article,
            onTap: () => _openArticle(context, ref, article),
            onDelete: () => _deleteArticle(context, ref, article.id),
            onToggleRead: () => _toggleRead(ref, article),
          );
        },
      ),
    );
  }

  void _openAddArticle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddArticleScreen(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openArticle(BuildContext context, WidgetRef ref, dynamic article) {
    // Mark as read and open URL
    ref.read(articlesProvider.notifier).markAsRead(article.id);
    // TODO: Open URL with url_launcher
  }

  void _deleteArticle(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除しますか？'),
        content: const Text('この記事をリストから削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(articlesProvider.notifier).deleteArticle(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _toggleRead(WidgetRef ref, dynamic article) {
    final notifier = ref.read(articlesProvider.notifier);
    if (article.status.name == 'unread') {
      notifier.markAsRead(article.id);
    } else {
      notifier.markAsUnread(article.id);
    }
  }
}
