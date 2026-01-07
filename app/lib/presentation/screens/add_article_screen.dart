import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../services/metadata_service.dart';

/// Screen for adding a new article
class AddArticleScreen extends ConsumerStatefulWidget {
  /// Optional initial URL (from share intent)
  final String? initialUrl;

  const AddArticleScreen({super.key, this.initialUrl});

  @override
  ConsumerState<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends ConsumerState<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _memoController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  UrlMetadata? _previewMetadata;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _fetchPreview();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _fetchPreview() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final metadataService = ref.read(metadataServiceProvider);
    if (!metadataService.isValidUrl(url)) {
      setState(() {
        _error = '有効なURLを入力してください';
        _previewMetadata = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final metadata = await metadataService.fetchMetadata(url);
      setState(() {
        _previewMetadata = metadata;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'メタデータの取得に失敗しました';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final memo = _memoController.text.trim();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final article = await ref.read(articlesProvider.notifier).addFromUrl(
            url,
            memo: memo.isEmpty ? null : memo,
          );

      if (article == null) {
        setState(() {
          _error = 'このURLは既に追加されています';
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${article.title}」を追加しました！'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = '記事の追加に失敗しました';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事を追加'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveArticle,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('追加'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // URL input
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: _urlController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _urlController.clear();
                          setState(() {
                            _previewMetadata = null;
                            _error = null;
                          });
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                setState(() {}); // Update UI for clear button
              },
              onFieldSubmitted: (_) => _fetchPreview(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URLを入力してください';
                }
                final metadataService = ref.read(metadataServiceProvider);
                if (!metadataService.isValidUrl(value.trim())) {
                  return '有効なURLを入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Fetch preview button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _fetchPreview,
              icon: const Icon(Icons.search),
              label: const Text('プレビューを取得'),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Preview card
            if (_previewMetadata != null) ...[
              const SizedBox(height: 20),
              const Text(
                'プレビュー',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildPreviewCard(),
            ],

            const SizedBox(height: 20),

            // Memo input
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                hintText: 'なぜ読みたいと思ったか...',
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final metadata = _previewMetadata!;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          if (metadata.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  metadata.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 48),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source badge
                if (metadata.sourceName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      metadata.sourceName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                if (metadata.sourceName != null) const SizedBox(height: 8),

                // Title
                Text(
                  metadata.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (metadata.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    metadata.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
