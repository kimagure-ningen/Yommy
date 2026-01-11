import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/article.dart';
import '../../core/theme/app_theme.dart';

/// Sleek article card with swipe actions
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
          SlidableAction(
            onPressed: (_) => onToggleRead(),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: isRead ? 'Unread' : 'Read',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.destructive,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
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
          child: Stack(
            children: [
              if (!isRead)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.accentForeground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              
              Opacity(
                opacity: isRead ? 0.7 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSourceRow(),
                            const SizedBox(height: 8),
                            
                            Text(
                              article.title,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cardForeground,
                                decoration: isRead ? TextDecoration.lineThrough : null,
                                decorationColor: AppColors.mutedForeground,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            if (article.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                article.description!,
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 14,
                                  color: AppColors.mutedForeground,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            
                            if (article.memo != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E6),
                                  border: Border.all(
                                    color: const Color(0xFFFFE4B5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Iconify(
                                      'solar:notes-bold',
                                      size: 14,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        article.memo!,
                                        style: GoogleFonts.instrumentSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFF92400E),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isRead ? AppColors.secondary : AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isRead ? 'Read' : 'Unread',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isRead
                                          ? AppColors.mutedForeground
                                          : AppColors.accentForeground,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: Iconify(
                                    'solar:menu-dots-bold',
                                    size: 16,
                                    color: AppColors.mutedForeground,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      if (article.hasThumbnail) ...[
                        const SizedBox(width: 16),
                        _buildThumbnail(),
                      ],
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

  Widget _buildSourceRow() {
    return Row(
      children: [
        if (article.isFromKnownSource)
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Iconify(
                'solar:bookmark-bold',
                size: 10,
                color: AppColors.primary,
              ),
            ),
          ),
        if (article.isFromKnownSource) const SizedBox(width: 8),
        
        Expanded(
          child: Text(
            article.sourceName ?? 'Unknown',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        Text(
          _formatDate(article.createdAt),
          style: GoogleFonts.instrumentSans(
            fontSize: 10,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 96,
        height: 96,
        child: CachedNetworkImage(
          imageUrl: article.thumbnailUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: AppColors.secondary,
            child: Center(
              child: Iconify(
                'solar:image-bold',
                size: 32,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.secondary,
            child: Center(
              child: Iconify(
                'solar:image-bold',
                size: 32,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}