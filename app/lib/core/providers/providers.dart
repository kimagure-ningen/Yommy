import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/article.dart';
import '../../data/models/reminder_settings.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/metadata_service.dart';
import '../../services/notification_service.dart';

// =============================================================================
// Repository Providers
// =============================================================================

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// =============================================================================
// Service Providers
// =============================================================================

final metadataServiceProvider = Provider<MetadataService>((ref) {
  return MetadataService.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// =============================================================================
// Article State
// =============================================================================

/// Notifier for managing articles state
class ArticlesNotifier extends StateNotifier<List<Article>> {
  final ArticleRepository _repository;
  final MetadataService _metadataService;

  ArticlesNotifier(this._repository, this._metadataService) : super([]) {
    _loadArticles();
  }

  void _loadArticles() {
    state = _repository.getSortedByDate();
  }

  /// Refresh article list
  void refresh() {
    _loadArticles();
  }

  /// Add article from URL
  Future<Article?> addFromUrl(String url, {String? memo}) async {
    // Check for duplicate
    if (_repository.urlExists(url)) {
      return null; // Already exists
    }

    // Fetch metadata
    final metadata = await _metadataService.fetchMetadata(url);

    // Create article
    final article = Article(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: metadata.url,
      title: metadata.title,
      description: metadata.description,
      thumbnailUrl: metadata.thumbnailUrl,
      sourceName: metadata.sourceName,
      memo: memo,
      createdAt: DateTime.now(),
    );

    // Save to repository
    await _repository.add(article);

    // Update state
    _loadArticles();

    return article;
  }

  /// Update article
  Future<void> updateArticle(Article article) async {
    await _repository.update(article);
    _loadArticles();
  }

  /// Delete article
  Future<void> deleteArticle(String id) async {
    await _repository.delete(id);
    _loadArticles();
  }

  /// Mark article as read
  Future<void> markAsRead(String id) async {
    final article = _repository.getById(id);
    if (article != null) {
      article.markAsRead();
      _loadArticles();
    }
  }

  /// Mark article as unread
  Future<void> markAsUnread(String id) async {
    final article = _repository.getById(id);
    if (article != null) {
      article.markAsUnread();
      _loadArticles();
    }
  }
}

final articlesProvider =
    StateNotifierProvider<ArticlesNotifier, List<Article>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  final metadataService = ref.watch(metadataServiceProvider);
  return ArticlesNotifier(repository, metadataService);
});

// =============================================================================
// Filtered Article Providers
// =============================================================================

/// Provider for unread articles only
final unreadArticlesProvider = Provider<List<Article>>((ref) {
  final articles = ref.watch(articlesProvider);
  return articles.where((a) => a.status == ArticleStatus.unread).toList();
});

/// Provider for read articles only
final readArticlesProvider = Provider<List<Article>>((ref) {
  final articles = ref.watch(articlesProvider);
  return articles.where((a) => a.status == ArticleStatus.read).toList();
});

/// Provider for article counts
final articleCountsProvider = Provider<ArticleCounts>((ref) {
  final articles = ref.watch(articlesProvider);
  return ArticleCounts(
    total: articles.length,
    unread: articles.where((a) => a.status == ArticleStatus.unread).length,
    read: articles.where((a) => a.status == ArticleStatus.read).length,
  );
});

class ArticleCounts {
  final int total;
  final int unread;
  final int read;

  const ArticleCounts({
    required this.total,
    required this.unread,
    required this.read,
  });
}

// =============================================================================
// Search Functionality
// =============================================================================

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered articles based on current filter and search
final filteredAndSearchedArticlesProvider = Provider<List<Article>>((ref) {
  final filter = ref.watch(articleFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final articles = ref.watch(articlesProvider);

  // First, filter by status
  List<Article> filtered;
  switch (filter) {
    case ArticleFilter.all:
      filtered = articles;
      break;
    case ArticleFilter.unread:
      filtered = articles.where((a) => a.status == ArticleStatus.unread).toList();
      break;
    case ArticleFilter.read:
      filtered = articles.where((a) => a.status == ArticleStatus.read).toList();
      break;
  }

  // Then, apply search filter
  if (searchQuery.isEmpty) {
    return filtered;
  }

  return filtered.where((article) {
    // Search in title
    if (article.title.toLowerCase().contains(searchQuery)) {
      return true;
    }
    
    // Search in description
    if (article.description != null &&
        article.description!.toLowerCase().contains(searchQuery)) {
      return true;
    }
    
    // Search in URL
    if (article.url.toLowerCase().contains(searchQuery)) {
      return true;
    }
    
    // Search in memo
    if (article.memo != null &&
        article.memo!.toLowerCase().contains(searchQuery)) {
      return true;
    }
    
    // Search in source name
    if (article.sourceName != null &&
        article.sourceName!.toLowerCase().contains(searchQuery)) {
      return true;
    }
    
    return false;
  }).toList();
});

// =============================================================================
// Reminder Settings State
// =============================================================================

/// Notifier for managing reminder settings
class ReminderSettingsNotifier extends StateNotifier<ReminderSettings> {
  final SettingsRepository _repository;

  ReminderSettingsNotifier(this._repository)
      : super(_repository.getReminderSettings());

  /// Update settings
  Future<void> updateSettings({
    bool? enabled,
    int? hour,
    int? minute,
    ReminderMode? mode,
    int? articleCount,
    List<int>? activeDays,
  }) async {
    state = await _repository.updateReminderSettings(
      enabled: enabled,
      hour: hour,
      minute: minute,
      mode: mode,
      articleCount: articleCount,
      activeDays: activeDays,
    );
  }

  /// Toggle enabled state
  Future<void> toggleEnabled() async {
    await updateSettings(enabled: !state.enabled);
  }

  /// Set reminder time
  Future<void> setTime(int hour, int minute) async {
    await updateSettings(hour: hour, minute: minute);
  }

  /// Set reminder mode
  Future<void> setMode(ReminderMode mode) async {
    await updateSettings(mode: mode);
  }

  /// Toggle a specific day
  Future<void> toggleDay(int day) async {
    final newDays = List<int>.from(state.activeDays);
    if (newDays.contains(day)) {
      newDays.remove(day);
    } else {
      newDays.add(day);
    }
    newDays.sort();
    await updateSettings(activeDays: newDays);
  }
}

final reminderSettingsProvider =
    StateNotifierProvider<ReminderSettingsNotifier, ReminderSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ReminderSettingsNotifier(repository);
});

// =============================================================================
// UI State Providers
// =============================================================================

/// Current filter for article list
enum ArticleFilter { all, unread, read }

final articleFilterProvider = StateProvider<ArticleFilter>((ref) {
  return ArticleFilter.all;
});

/// Filtered articles based on current filter (without search)
final filteredArticlesProvider = Provider<List<Article>>((ref) {
  final filter = ref.watch(articleFilterProvider);
  final articles = ref.watch(articlesProvider);

  switch (filter) {
    case ArticleFilter.all:
      return articles;
    case ArticleFilter.unread:
      return articles.where((a) => a.status == ArticleStatus.unread).toList();
    case ArticleFilter.read:
      return articles.where((a) => a.status == ArticleStatus.read).toList();
  }
});