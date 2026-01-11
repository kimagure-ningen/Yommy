import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../services/share_intent_service.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import 'add_article_screen.dart';
import 'settings_screen.dart';

/// Main home screen showing article list
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSharedURLs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSharedURLs();
    }
  }

  Future<void> _checkSharedURLs() async {
    final shareService = ShareIntentService.instance;
    final urls = await shareService.getSharedURLs();

    if (urls.isEmpty) return;

    await shareService.clearSharedURLs();

    int addedCount = 0;
    for (final url in urls) {
      final article = await ref.read(articlesProvider.notifier).addFromUrl(url);
      if (article != null) {
        addedCount++;
      }
    }

    if (addedCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount 件の記事を追加しました！'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(filteredArticlesProvider);
    final counts = ref.watch(articleCountsProvider);

    final filteredArticles = _searchQuery.isEmpty
        ? articles
        : articles.where((article) {
            final query = _searchQuery.toLowerCase();
            return article.title.toLowerCase().contains(query) ||
                (article.description?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _buildStatsCards(counts),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: FilterChips(),
            ),
            Expanded(
              child: filteredArticles.isEmpty
                  ? const EmptyState()
                  : _buildArticleList(filteredArticles),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddArticle(context),
        child: Iconify(
          'solar:add-circle-bold',
          size: 32,
          color: AppColors.primaryForeground,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Iconify(
                'solar:bookmark-bold',
                size: 20,
                color: AppColors.primaryForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Yommy',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: Iconify(
              'solar:magnifer-linear',
              size: 24,
              color: AppColors.mutedForeground,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
          IconButton(
            onPressed: () => _openSettings(context),
            icon: Iconify(
              'solar:settings-bold',
              size: 24,
              color: AppColors.mutedForeground,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ArticleCounts counts) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: 'solar:documents-bold',
            iconColor: AppColors.primary,
            iconBgColor: AppColors.secondary,
            count: counts.total,
            label: 'TOTAL',
            countColor: AppColors.foreground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: 'solar:bookmark-circle-bold',
            iconColor: AppColors.accentForeground,
            iconBgColor: AppColors.accent.withOpacity(0.2),
            count: counts.unread,
            label: 'UNREAD',
            countColor: AppColors.accentForeground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: 'solar:check-circle-bold',
            iconColor: AppColors.success,
            iconBgColor: const Color(0xFFDCFCE7),
            count: counts.read,
            label: 'READ',
            countColor: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required Color iconColor,
    required Color iconBgColor,
    required int count,
    required String label,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Iconify(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedForeground,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList(List<dynamic> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(articlesProvider.notifier).refresh();
      },
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: articles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleCard(
            article: article,
            onTap: () => _openArticle(article),
            onDelete: () => _deleteArticle(article.id),
            onToggleRead: () => _toggleRead(article),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: 'solar:home-2-bold',
                label: 'Home',
                isSelected: _selectedTabIndex == 0,
                onTap: () => setState(() => _selectedTabIndex = 0),
              ),
              _buildNavItem(
                icon: 'solar:star-bold',
                label: 'Favorites',
                isSelected: _selectedTabIndex == 1,
                onTap: () => setState(() => _selectedTabIndex = 1),
              ),
              _buildNavItem(
                icon: 'solar:user-bold',
                label: 'Profile',
                isSelected: _selectedTabIndex == 2,
                onTap: () => setState(() => _selectedTabIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.mutedForeground,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Articles',
          style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter keywords...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openAddArticle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddArticleScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _openArticle(dynamic article) {
    ref.read(articlesProvider.notifier).markAsRead(article.id);
  }

  void _deleteArticle(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Article?',
          style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.bold),
        ),
        content: const Text('This article will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(articlesProvider.notifier).deleteArticle(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleRead(dynamic article) {
    final notifier = ref.read(articlesProvider.notifier);
    if (article.status.name == 'unread') {
      notifier.markAsRead(article.id);
    } else {
      notifier.markAsUnread(article.id);
    }
  }
}