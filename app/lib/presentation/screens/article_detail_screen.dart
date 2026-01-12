import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/article.dart';
import '../../services/summarizer_service.dart';

/// Article detail screen with WebView and memo/summary features
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
  late final WebViewController _webViewController;
  final _memoController = TextEditingController();
  
  bool _isLoading = true;
  bool _showMemo = false;
  bool _isGeneratingSummary = false;
  String? _summary;

  @override
  void initState() {
    super.initState();
    _memoController.text = widget.article.memo ?? '';
    _initWebView();
    
    // Mark as read when opened
    Future.microtask(() {
      ref.read(articlesProvider.notifier).markAsRead(widget.article.id);
    });
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // WebView
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _webViewController),
                      if (_isLoading)
                        Container(
                          color: AppColors.backgroundWhite,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Floating action buttons
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildFloatingMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.neutral100, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: PhosphorIcon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
              color: AppColors.textPrimary,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.article.title,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.article.sourceName != null)
                  Text(
                    widget.article.sourceName!,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Read status toggle
          IconButton(
            onPressed: _toggleReadStatus,
            icon: PhosphorIcon(
              widget.article.status == ArticleStatus.read
                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                  : PhosphorIcons.circle(PhosphorIconsStyle.regular),
              color: widget.article.status == ArticleStatus.read
                  ? AppColors.readAccent
                  : AppColors.textSecondary,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Memo button
        FloatingActionButton(
          heroTag: 'memo',
          onPressed: () => _showMemoSheet(),
          backgroundColor: AppColors.backgroundWhite,
          child: PhosphorIcon(
            PhosphorIcons.note(PhosphorIconsStyle.bold),
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Summary button
        FloatingActionButton(
          heroTag: 'summary',
          onPressed: () => _showSummarySheet(),
          backgroundColor: AppColors.accent,
          child: _isGeneratingSummary
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : PhosphorIcon(
                  PhosphorIcons.sparkle(PhosphorIconsStyle.bold),
                  color: AppColors.textPrimary,
                  size: 24,
                ),
        ),
      ],
    );
  }

  void _toggleReadStatus() {
    final notifier = ref.read(articlesProvider.notifier);
    if (widget.article.status == ArticleStatus.read) {
      notifier.markAsUnread(widget.article.id);
    } else {
      notifier.markAsRead(widget.article.id);
    }
    setState(() {}); // Refresh UI
  }

  void _showMemoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMemoSheet(),
    );
  }

  Widget _buildMemoSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
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
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.note(PhosphorIconsStyle.bold),
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'メモ',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _saveMemo();
                    Navigator.pop(context);
                  },
                  child: Text(
                    '保存',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: AppColors.neutral100, height: 1),
          
          // Memo input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _memoController,
                maxLines: null,
                autofocus: true,
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'この記事について思ったこと、覚えておきたいことを書いてください...',
                  hintStyle: GoogleFonts.instrumentSans(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveMemo() {
    final memo = _memoController.text.trim();
    final updatedArticle = widget.article.copyWith(
      memo: memo.isEmpty ? null : memo,
    );
    ref.read(articlesProvider.notifier).updateArticle(updatedArticle);
  }

  void _showSummarySheet() {
    if (_summary == null && !_isGeneratingSummary) {
      _generateSummary();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSummarySheet(),
    );
  }

  Widget _buildSummarySheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.sparkle(PhosphorIconsStyle.bold),
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI要約',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_summary != null)
                  IconButton(
                    onPressed: _copyToMemo,
                    icon: PhosphorIcon(
                      PhosphorIcons.copySimple(PhosphorIconsStyle.regular),
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: 'メモにコピー',
                  ),
              ],
            ),
          ),
          
          Divider(color: AppColors.neutral100, height: 1),
          
          // Summary content
          Expanded(
            child: _isGeneratingSummary
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.accent),
                        const SizedBox(height: 16),
                        Text(
                          '要約を生成中...',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _summary != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIcons.info(PhosphorIconsStyle.regular),
                                    color: AppColors.accent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ローカル要約（重要文抽出）',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Summary text
                            Text(
                              _summary!,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          '要約の生成に失敗しました',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      // Get HTML content from WebView
      final html = await _webViewController.runJavaScriptReturningResult(
        'document.documentElement.outerHTML',
      ) as String;
      
      // Remove quotes from JavaScript string
      final cleanedHtml = html.replaceAll(RegExp(r'^"|"$'), '');
      
      // Generate summary
      final summary = await SummarizerService.instance.summarizeHtml(cleanedHtml);
      
      setState(() {
        _summary = summary;
        _isGeneratingSummary = false;
      });
    } catch (e) {
      setState(() {
        _summary = '要約の生成中にエラーが発生しました。ページの読み込みが完了してから再度お試しください。';
        _isGeneratingSummary = false;
      });
    }
  }

  void _copyToMemo() {
    if (_summary != null) {
      final currentMemo = _memoController.text.trim();
      final newMemo = currentMemo.isEmpty
          ? '【AI要約】\n$_summary'
          : '$currentMemo\n\n【AI要約】\n$_summary';
      
      _memoController.text = newMemo;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'メモにコピーしました',
            style: GoogleFonts.instrumentSans(),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}