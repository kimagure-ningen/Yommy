import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/article.dart';

/// Repository for managing Article data
class ArticleRepository {
  static const String _boxName = 'articles';

  Box<Article> get _box => Hive.box<Article>(_boxName);

  /// Get all articles
  List<Article> getAll() {
    return _box.values.toList();
  }

  /// Get all unread articles
  List<Article> getUnread() {
    return _box.values
        .where((article) => article.status == ArticleStatus.unread)
        .toList();
  }

  /// Get all read articles
  List<Article> getRead() {
    return _box.values
        .where((article) => article.status == ArticleStatus.read)
        .toList();
  }

  /// Get article by ID
  Article? getById(String id) {
    try {
      return _box.values.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new article
  Future<void> add(Article article) async {
    await _box.put(article.id, article);
  }

  /// Update an existing article
  Future<void> update(Article article) async {
    await article.save();
  }

  /// Delete an article by ID
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete multiple articles
  Future<void> deleteMultiple(List<String> ids) async {
    await _box.deleteAll(ids);
  }

  /// Check if URL already exists
  bool urlExists(String url) {
    return _box.values.any((article) => article.url == url);
  }

  /// Get articles sorted by creation date (newest first)
  List<Article> getSortedByDate({bool ascending = false}) {
    final articles = getAll();
    articles.sort((a, b) => ascending
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return articles;
  }

  /// Get random unread articles for reminder
  List<Article> getRandomUnread(int count) {
    final unread = getUnread();
    if (unread.isEmpty) return [];

    unread.shuffle();
    return unread.take(count).toList();
  }

  /// Get oldest unread articles for reminder
  List<Article> getOldestUnread(int count) {
    final unread = getUnread();
    unread.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return unread.take(count).toList();
  }

  /// Get newest unread articles for reminder
  List<Article> getNewestUnread(int count) {
    final unread = getUnread();
    unread.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return unread.take(count).toList();
  }

  /// Get total count
  int get totalCount => _box.length;

  /// Get unread count
  int get unreadCount => getUnread().length;

  /// Get read count
  int get readCount => getRead().length;

  /// Watch for changes (returns a listenable)
  Listenable watchAll() => _box.listenable();
}
