import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Slidable(
      key: ValueKey(article.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (_) {
              onToggleRead();
            },
            backgroundColor: isRead ? AppColors.unreadAccent : AppColors.readAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  isRead 
                      ? PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.bold)
                      : PhosphorIcons.check(PhosphorIconsStyle.bold),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  isRead ? '未読に' : '読了',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) {
              onDelete();
            },
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIcons.trash(PhosphorIconsStyle.bold),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '削除',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral100, width: 1),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isRead ? AppColors.readAccent : AppColors.unreadAccent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: favicon + source + menu
                        Row(
                          children: [
                            // Favicon placeholder
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: PhosphorIcon(
                                  PhosphorIcons.globe(PhosphorIconsStyle.regular),
                                  color: AppColors.textSecondary,
                                  size: 10,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Source name
                            if (article.isFromKnownSource)
                              Text(
                                article.sourceName!,
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            
                            const SizedBox(width: 8),
                            
                            // Timestamp
                            Text(
                              _formatDate(article.createdAt),
                              style: GoogleFonts.instrumentSans(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Menu button
                            PhosphorIcon(
                              PhosphorIcons.dotsThree(PhosphorIconsStyle.bold),
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Title
                        Text(
                          article.title,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.3,
                            decoration: isRead ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Description
                        if (article.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            article.description!,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        // Memo
                        if (article.memo != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.neutral100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.note(PhosphorIconsStyle.regular),
                                  color: AppColors.textSecondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    article.memo!,
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isRead
                                ? AppColors.readAccent.withOpacity(0.1)
                                : AppColors.unreadAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PhosphorIcon(
                                isRead
                                    ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                                    : PhosphorIcons.circle(PhosphorIconsStyle.regular),
                                color: isRead ? AppColors.readAccent : AppColors.unreadAccent,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isRead ? '読了' : '未読',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 11,
                                  color: isRead ? AppColors.readAccent : AppColors.unreadAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Thumbnail
                if (article.hasThumbnail)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: 100,
                      child: CachedNetworkImage(
                        imageUrl: article.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(),
                        errorWidget: (_, __, ___) => _buildPlaceholder(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.neutral100,
      child: Center(
        child: PhosphorIcon(
          PhosphorIcons.article(PhosphorIconsStyle.regular),
          size: 32,
          color: AppColors.textTertiary,
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
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}週間前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}