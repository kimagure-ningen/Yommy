import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/providers/providers.dart';
import '../../services/metadata_service.dart';

/// 記事追加画面
class AddArticleScreen extends ConsumerStatefulWidget {
  /// 初期URL（共有機能から渡される場合）
  final String? initialUrl;

  const AddArticleScreen({super.key, this.initialUrl});

  @override
  ConsumerState<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends ConsumerState<AddArticleScreen> {
  final _urlController = TextEditingController();
  final _memoController = TextEditingController();
  final _urlFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _urlError;
  bool _fetchError = false;
  UrlMetadata? _previewMetadata;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPreview();
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _memoController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _urlController.text = clipboardData.text!;
        _urlError = null;
        _fetchError = false;
      });
    }
  }

  Future<void> _fetchPreview() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final metadataService = ref.read(metadataServiceProvider);
    if (!metadataService.isValidUrl(url)) {
      setState(() {
        _urlError = '有効なURLを入力してください';
        _previewMetadata = null;
        _fetchError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _urlError = null;
      _fetchError = false;
      _previewMetadata = null;
    });

    try {
      final metadata = await metadataService.fetchMetadata(url);
      setState(() {
        _previewMetadata = metadata;
        _isLoading = false;
        _fetchError = false;
      });
    } catch (e) {
      setState(() {
        _fetchError = true;
        _isLoading = false;
        _previewMetadata = null;
      });
    }
  }

  Future<void> _saveArticle() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _urlError = '有効なURLを入力してください';
      });
      return;
    }

    final metadataService = ref.read(metadataServiceProvider);
    if (!metadataService.isValidUrl(url)) {
      setState(() {
        _urlError = '有効なURLを入力してください';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _urlError = null;
    });

    try {
      final memo = _memoController.text.trim();
      final article = await ref.read(articlesProvider.notifier).addFromUrl(
            url,
            memo: memo.isEmpty ? null : memo,
          );

      if (article == null) {
        setState(() {
          _urlError = 'この記事は既に追加されています';
          _isSaving = false;
        });
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${article.title}」を追加しました！'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _urlError = '記事の追加に失敗しました';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // URL Input Section
                          _buildUrlInputSection(),

                          const SizedBox(height: 32),

                          // Preview Section
                          if (_isLoading) _buildLoadingState(),
                          if (_previewMetadata != null) _buildPreviewSection(),
                          if (_fetchError) _buildErrorState(),

                          if (_previewMetadata != null || _fetchError) ...[
                            const SizedBox(height: 32),
                            _buildMemoSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Save Button (Fixed at bottom)
          if (_previewMetadata != null || _fetchError)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSaveButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
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
          Text(
            '記事を追加',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '記事のURL',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        
        // URL Input Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _urlController,
            focusNode: _urlFocusNode,
            decoration: InputDecoration(
              hintText: '記事のURLをペースト',
              hintStyle: GoogleFonts.instrumentSans(
                color: const Color(0xFF94A3B8),
                fontSize: 16,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/solar-link-bold.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF64748B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: _pasteFromClipboard,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/solar-clipboard-list-bold.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF1E293B),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
            onChanged: (_) {
              if (_urlError != null) {
                setState(() {
                  _urlError = null;
                });
              }
            },
          ),
        ),

        // URL Error Message
        if (_urlError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/solar-danger-bold.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFEF4444),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _urlError!,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Fetch Preview Button
        GestureDetector(
          onTap: _isLoading ? null : _fetchPreview,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                    ),
                  )
                else
                  SvgPicture.asset(
                    'assets/icons/solar-refresh-bold.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1E293B),
                      BlendMode.srcIn,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'プレビューを取得',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '記事のプレビュー',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        
        // Skeleton Loading
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image skeleton
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source skeleton
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Title skeleton
                    Container(
                      width: double.infinity,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description skeleton
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '記事のプレビュー',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'メタデータ取得完了',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF1E293B).withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (_previewMetadata!.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: _previewMetadata!.thumbnailUrl!,
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
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source
                    if (_previewMetadata!.sourceName != null)
                      Row(
                        children: [
                          // Google Favicon Service を使用してファビコンを取得
                          CachedNetworkImage(
                            imageUrl: 'https://www.google.com/s2/favicons?domain=${Uri.parse(_previewMetadata!.url).host}&sz=32',
                            width: 20,
                            height: 20,
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _previewMetadata!.sourceName!,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                    if (_previewMetadata!.sourceName != null)
                      const SizedBox(height: 12),

                    // Title
                    Text(
                      _previewMetadata!.title,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),

                    // Description
                    if (_previewMetadata!.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _previewMetadata!.description!,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/solar-cloud-cross-bold.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFEF4444),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'メタデータを取得できませんでした',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'このURLから情報を取得できませんでした。手動で保存することもできます。',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _fetchPreview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '再試行',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/solar-notes-bold.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF64748B),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'メモを追加（任意）',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _memoController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'なぜ読みたいと思ったか...',
              hintStyle: GoogleFonts.instrumentSans(
                color: const Color(0xFF94A3B8),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFC).withOpacity(0),
            const Color(0xFFF8FAFC).withOpacity(0.95),
            const Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveArticle,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _isSaving ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
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
              if (_isSaving)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/icons/solar-bookmark-opened-bold.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '記事を保存',
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}