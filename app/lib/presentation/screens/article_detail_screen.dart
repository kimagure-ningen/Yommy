import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/providers.dart';
import '../../data/models/article.dart';

/// 記事詳細画面
class ArticleDetailScreen extends ConsumerStatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _showWebView = false;
  late final WebViewController _webViewController;
  bool _isWebViewLoading = true;

  @override
  void initState() {
    super.initState();
    // Mark as read when opened
    Future.microtask(() {
      ref.read(articlesProvider.notifier).markAsRead(widget.article.id);
    });
    
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isWebViewLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isWebViewLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  // 文字数を計算
  int _getWordCount() {
    if (widget.article.description == null) return 0;
    return widget.article.description!.length;
  }

  // 読了時間を計算（日本語の平均読書速度: 500文字/分）
  String _getReadingTime() {
    final wordCount = _getWordCount();
    if (wordCount == 0) return '1分';
    final minutes = (wordCount / 500).ceil();
    return '${minutes}分';
  }

  // 難易度を判定
  String _getComplexity() {
    final wordCount = _getWordCount();
    if (wordCount < 300) return '初級';
    if (wordCount < 800) return '中級';
    return '上級';
  }

  // 類似記事を取得（同じソースから）
  List<Article> _getSimilarArticles() {
    final allArticles = ref.watch(articlesProvider);
    if (widget.article.sourceName == null) {
      // ソース名がない場合は最新の記事を返す
      return allArticles
          .where((a) => a.id != widget.article.id)
          .take(2)
          .toList();
    }
    
    return allArticles
        .where((a) =>
            a.id != widget.article.id &&
            a.sourceName == widget.article.sourceName)
        .take(2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView) {
      return _buildWebViewScreen();
    }
    return _buildDetailScreen();
  }

  Widget _buildWebViewScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildWebViewHeader(),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isWebViewLoading)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E293B),
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

  Widget _buildWebViewHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showWebView = false),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/solar-arrow-left-linear.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0F172A),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.article.title,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailScreen() {
    final isRead = widget.article.status == ArticleStatus.read;
    final similarArticles = _getSimilarArticles();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              // Sticky Header
              _buildHeader(isRead),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image
                      if (widget.article.thumbnailUrl != null)
                        _buildHeroImage(isRead),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Meta Info
                            _buildMetaInfo(),

                            const SizedBox(height: 16),

                            // Title
                            Text(
                              widget.article.title,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                                height: 1.2,
                              ),
                            ),

                            // Description
                            if (widget.article.description != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                widget.article.description!,
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 18,
                                  color: const Color(0xFF64748B),
                                  height: 1.6,
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Open Full Article Button
                            _buildOpenArticleButton(),

                            const SizedBox(height: 32),

                            // Memo Section
                            if (widget.article.memo != null)
                              _buildMemoSection(),

                            // Article Insights
                            _buildArticleInsights(),

                            const SizedBox(height: 40),

                            // Similar Articles
                            if (similarArticles.isNotEmpty)
                              _buildSimilarArticles(similarArticles),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRead) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/solar-arrow-left-linear.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0F172A),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Share Button
          GestureDetector(
            onTap: _shareArticle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.shareFat(PhosphorIconsStyle.fill),
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Toggle Read Button
          GestureDetector(
            onTap: _toggleReadStatus,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: const Color(0xFF3730A3),
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Delete Button
          GestureDetector(
            onTap: _deleteArticle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.trash(PhosphorIconsStyle.fill),
                  color: const Color(0xFFEF4444),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isRead) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: widget.article.thumbnailUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFFF1F5F9),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ),
        
        // Status Badge
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              isRead ? '既読' : '未読',
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isRead ? const Color(0xFF64748B) : const Color(0xFF3730A3),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfo() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Source
        if (widget.article.sourceName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFE2E8F0).withOpacity(0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://www.google.com/s2/favicons?domain=${Uri.parse(widget.article.url).host}&sz=32',
                  width: 16,
                  height: 16,
                  errorWidget: (context, url, error) =>
                      const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.article.sourceName!,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

        // Date Added
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/solar-calendar-bold.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF64748B),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '追加日: ${_formatDate(widget.article.createdAt)}',
                style: GoogleFonts.instrumentSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        // Reading Time
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/solar-clock-circle-bold.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF64748B),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_getReadingTime()}で読めます',
                style: GoogleFonts.instrumentSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenArticleButton() {
    return GestureDetector(
      onTap: () => setState(() => _showWebView = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/solar-globus-bold.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '記事を開く',
              style: GoogleFonts.instrumentSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/solar-notes-bold.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFD97706),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'あなたのメモ',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF78350F),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _editMemo,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE68A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/solar-pen-bold.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF92400E),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.article.memo!,
            style: GoogleFonts.instrumentSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF78350F),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '最終更新: ${_formatDate(widget.article.createdAt)}',
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD97706).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記事の詳細',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '難易度',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                          color: const Color(0xFF4338CA),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getComplexity(),
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文字数',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.textAa(PhosphorIconsStyle.fill),
                          color: const Color(0xFF10B981),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_getWordCount()}文字',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimilarArticles(List<Article> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '類似記事',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                // すべて表示機能（将来の実装）
              },
              child: Text(
                'すべて表示',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3730A3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...articles.map((article) => _buildSimilarArticleCard(article)),
      ],
    );
  }

  Widget _buildSimilarArticleCard(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE2E8F0).withOpacity(0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            if (article.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: article.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF1F5F9),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (article.sourceName != null)
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: 'https://www.google.com/s2/favicons?domain=${Uri.parse(article.url).host}&sz=32',
                          width: 12,
                          height: 12,
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          article.sourceName!,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  void _shareArticle() {
    Clipboard.setData(ClipboardData(text: widget.article.url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'URLをコピーしました',
          style: GoogleFonts.instrumentSans(),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleReadStatus() {
    final notifier = ref.read(articlesProvider.notifier);
    if (widget.article.status == ArticleStatus.read) {
      notifier.markAsUnread(widget.article.id);
    } else {
      notifier.markAsRead(widget.article.id);
    }
    setState(() {});
  }

  void _deleteArticle() {
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
              ref.read(articlesProvider.notifier).deleteArticle(widget.article.id);
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pop(context); // 詳細画面を閉じる
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

  void _editMemo() {
    final memoController = TextEditingController(text: widget.article.memo);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.note(PhosphorIconsStyle.fill),
                    color: const Color(0xFF1E293B),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'メモを編集',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      final memo = memoController.text.trim();
                      final updatedArticle = widget.article.copyWith(
                        memo: memo.isEmpty ? null : memo,
                      );
                      ref.read(articlesProvider.notifier).updateArticle(updatedArticle);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text(
                      '保存',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Memo input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: memoController,
                  autofocus: true,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'なぜ読みたいと思ったか...',
                    hintStyle: GoogleFonts.instrumentSans(
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}