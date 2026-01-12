import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../services/share_intent_service.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import 'add_article_screen.dart';
import 'article_detail_screen.dart';
import 'settings_screen.dart';

/// Main home screen showing article list
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  int _selectedTab = 0;
  final _searchController = TextEditingController();

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
    _searchController.dispose();
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
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedTab == 1) {
      return _buildProfileScreen();
    }
    return _buildHomeScreen();
  }

  Widget _buildHomeScreen() {
    final searchQuery = ref.watch(searchQueryProvider);
    final articles = ref.watch(filteredAndSearchedArticlesProvider);
    final counts = ref.watch(articleCountsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, counts),

            // Search bar (if active)
            if (searchQuery.isNotEmpty) _buildSearchBar(),

            // Filter tabs
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: FilterChips(),
            ),

            // Article list
            Expanded(
              child: articles.isEmpty
                  ? searchQuery.isNotEmpty
                      ? _buildNoSearchResults()
                      : const EmptyState()
                  : _buildArticleList(context, ref, articles),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddArticle(context),
        backgroundColor: AppColors.accent,
        child: PhosphorIcon(
          PhosphorIcons.plus(PhosphorIconsStyle.bold),
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ArticleCounts counts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Logo + Actions
          Row(
            children: [
              // Logo
              Text(
                'Yommy',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              
              // Search button
              IconButton(
                onPressed: () => _showSearchDialog(context),
                icon: PhosphorIcon(
                  PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              
              const SizedBox(width: 12),
              
              // Settings button
              IconButton(
                onPressed: () => _openSettings(context),
                icon: PhosphorIcon(
                  PhosphorIcons.gear(PhosphorIconsStyle.regular),
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  '未読',
                  counts.unread.toString(),
                  AppColors.unreadAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  '読了',
                  counts.read.toString(),
                  AppColors.readAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  '合計',
                  counts.total.toString(),
                  AppColors.neutral200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final searchQuery = ref.watch(searchQueryProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              searchQuery,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
            },
            icon: PhosphorIcon(
              PhosphorIcons.x(PhosphorIconsStyle.regular),
              color: AppColors.textSecondary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList(BuildContext context, WidgetRef ref, List<dynamic> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(articlesProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ArticleCard(
              article: article,
              onTap: () => _openArticle(context, article),
              onDelete: () => _deleteArticle(context, ref, article.id),
              onToggleRead: () => _toggleRead(ref, article),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
            color: AppColors.textSecondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            '検索結果が見つかりませんでした',
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral100, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                iconFilled: PhosphorIcons.house(PhosphorIconsStyle.fill),
                label: 'ホーム',
                index: 0,
              ),
              _buildNavItem(
                icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                iconFilled: PhosphorIcons.user(PhosphorIconsStyle.fill),
                label: 'プロフィール',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required PhosphorIconData icon,
    required PhosphorIconData iconFilled,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedTab == index;
    
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              isSelected ? iconFilled : icon,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    _searchController.clear();
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '記事を検索...',
                        hintStyle: GoogleFonts.instrumentSans(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.instrumentSans(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          ref.read(searchQueryProvider.notifier).state = query.trim();
                          Navigator.pop(dialogContext);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      Navigator.pop(dialogContext);
                    },
                    icon: PhosphorIcon(
                      PhosphorIcons.x(PhosphorIconsStyle.regular),
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.user(PhosphorIconsStyle.fill),
                color: AppColors.textSecondary,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'プロフィール機能は準備中です',
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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

  void _openArticle(BuildContext context, dynamic article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _deleteArticle(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '削除しますか？',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'この記事をリストから削除します。',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: GoogleFonts.instrumentSans(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(articlesProvider.notifier).deleteArticle(id);
              Navigator.pop(context);
            },
            child: Text(
              '削除',
              style: GoogleFonts.instrumentSans(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
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