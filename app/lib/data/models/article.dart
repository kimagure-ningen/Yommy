import 'package:hive/hive.dart';

part 'article.g.dart';

/// Status of an article in the reading list
@HiveType(typeId: 1)
enum ArticleStatus {
  @HiveField(0)
  unread,

  @HiveField(1)
  read,
}

/// Represents a saved article/link in Yommy
@HiveType(typeId: 0)
class Article extends HiveObject {
  /// Unique identifier
  @HiveField(0)
  final String id;

  /// The URL of the article
  @HiveField(1)
  final String url;

  /// Title of the article (auto-fetched or user-provided)
  @HiveField(2)
  String title;

  /// Description/excerpt of the article
  @HiveField(3)
  String? description;

  /// Thumbnail image URL
  @HiveField(4)
  String? thumbnailUrl;

  /// Source website name (e.g., "note", "Zenn")
  @HiveField(5)
  String? sourceName;

  /// User's personal memo/note
  @HiveField(6)
  String? memo;

  /// Current reading status
  @HiveField(7)
  ArticleStatus status;

  /// When this article was saved
  @HiveField(8)
  final DateTime createdAt;

  /// When this article was last read/opened
  @HiveField(9)
  DateTime? readAt;

  /// Tags for organization (future feature)
  @HiveField(10)
  List<String> tags;

  Article({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.sourceName,
    this.memo,
    this.status = ArticleStatus.unread,
    required this.createdAt,
    this.readAt,
    List<String>? tags,
  }) : tags = tags ?? [];

  /// Creates a copy with updated fields
  Article copyWith({
    String? title,
    String? description,
    String? thumbnailUrl,
    String? sourceName,
    String? memo,
    ArticleStatus? status,
    DateTime? readAt,
    List<String>? tags,
  }) {
    return Article(
      id: id,
      url: url,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceName: sourceName ?? this.sourceName,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      tags: tags ?? this.tags,
    );
  }

  /// Mark as read
  void markAsRead() {
    status = ArticleStatus.read;
    readAt = DateTime.now();
    save();
  }

  /// Mark as unread
  void markAsUnread() {
    status = ArticleStatus.unread;
    readAt = null;
    save();
  }

  /// Check if this is from a known source
  bool get isFromKnownSource =>
      sourceName != null && sourceName!.isNotEmpty;

  /// Check if this has a thumbnail
  bool get hasThumbnail =>
      thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

  @override
  String toString() => 'Article(id: $id, title: $title, status: $status)';
}
