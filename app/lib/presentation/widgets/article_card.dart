import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/article.dart';

/// Card widget for displaying an article
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleRead;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onDelete,
    required this.onToggleRead,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = article.status == ArticleStatus.read;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(article.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            // Toggle read/unread
            SlidableAction(
              onPressed: (_) => onToggleRead(),
              backgroundColor: isRead ? AppColors.unreadBadge : AppColors.readBadge,
              foregroundColor: Colors.white,
              icon: isRead ? Icons.mark_email_unread : Icons.check,
              label: isRead ? '未読に' : '読了',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            // Delete
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '削除',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Opacity(
              opacity: isRead ? 0.6 : 1.0,
              child: Row(
                children: [
                  // Thumbnail
                  _buildThumbnail(),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Source & status row
                          Row(
                            children: [
                              if (article.isFromKnownSource)
                                _buildSourceBadge(context),
                              const Spacer(),
                              _buildStatusBadge(context),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Title
                          Text(
                            article.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: isRead
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Description
                          if (article.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              article.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Memo
                          if (article.memo != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    article.memo!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Date
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(article.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
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
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(16),
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: article.hasThumbnail
            ? CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.article,
        size: 32,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSourceBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        article.sourceName!,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isRead = article.status == ArticleStatus.read;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.readBadge.withOpacity(0.2)
            : AppColors.unreadBadge.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isRead ? '読了' : '未読',
        style: TextStyle(
          fontSize: 10,
          color: isRead ? AppColors.readBadge : AppColors.unreadBadge,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今日';
    } else if (diff.inDays == 1) {
      return '昨日';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}日前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
