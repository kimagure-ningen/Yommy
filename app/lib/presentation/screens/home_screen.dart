import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/providers.dart';
import '../../data/models/article.dart';
import '../../services/share_intent_service.dart';
import '../widgets/article_card.dart';
import 'add_article_screen.dart';
import 'article_detail_screen.dart';
import 'settings_screen.dart';

/// メインのホーム画面
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
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
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
    final filter = ref.watch(articleFilterProvider);
    final articles = ref.watch(filteredArticlesProvider);
    final counts = ref.watch(articleCountsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(counts),

                // Filter Tabs
                _buildFilterTabs(filter),

                // Article List
                Expanded(
                  child: articles.isEmpty
                      ? _buildEmptyState()
                      : _buildArticleList(articles),
                ),
              ],
            ),
          ),

          // FAB
          Positioned(
            right: 24,
            bottom: 24,
            child: _buildFAB(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(ArticleCounts counts) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Top Row
          Row(
            children: [
              // Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/solar-bookmark-bold.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Yommy',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),

              // Search Button
              GestureDetector(
                onTap: () => _showSearchDialog(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/solar-magnifer-linear.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Settings Button
              GestureDetector(
                onTap: () => _openSettings(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/solar-settings-bold.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '合計',
                  counts.total.toString(),
                  'solar-documents-bold.svg',
                  const Color(0xFFF1F5F9),
                  const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '未読',
                  counts.unread.toString(),
                  'solar-bookmark-circle-bold.svg',
                  const Color(0xFFE0E7FF).withOpacity(0.2),
                  const Color(0xFF3730A3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '既読',
                  counts.read.toString(),
                  'solar-check-circle-bold.svg',
                  const Color(0xFFDCFCE7),
                  const Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String iconPath,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/$iconPath',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  textColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: label == '未読' ? textColor : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ).copyWith(
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ArticleFilter currentFilter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterTab(
              'すべて',
              ArticleFilter.all,
              currentFilter == ArticleFilter.all,
            ),
          ),
          Expanded(
            child: _buildFilterTab(
              '未読',
              ArticleFilter.unread,
              currentFilter == ArticleFilter.unread,
            ),
          ),
          Expanded(
            child: _buildFilterTab(
              '既読',
              ArticleFilter.read,
              currentFilter == ArticleFilter.read,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, ArticleFilter filter, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(articleFilterProvider.notifier).state = filter;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
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
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleList(List<Article> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(articlesProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ArticleCard(
              article: article,
              onTap: () => _openArticle(article),
              onDelete: () => _deleteArticle(article.id),
              onToggleRead: () => _toggleRead(article),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '📚',
              style: TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'まだ記事がありません',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              '気になる記事を追加して、読書リストを作りましょう！',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => _openAddArticle(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/solar-add-circle-bold.svg',
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  'ホーム',
                  'solar-home-2-bold.svg',
                  0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  'プロフィール',
                  'solar-user-bold.svg',
                  1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, String iconPath, int index) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/$iconPath',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/icons/solar-user-bold.svg',
                  width: 64,
                  height: 64,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF64748B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'プロフィール機能は準備中です',
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '記事を検索...',
                  hintStyle: GoogleFonts.instrumentSans(
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'assets/icons/solar-magnifer-linear.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddArticle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddArticleScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _deleteArticle(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '削除しますか？',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'この記事をリストから削除します。',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF64748B),
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
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRead(Article article) {
    final notifier = ref.read(articlesProvider.notifier);
    if (article.status == ArticleStatus.unread) {
      notifier.markAsRead(article.id);
    } else {
      notifier.markAsUnread(article.id);
    }
  }
}