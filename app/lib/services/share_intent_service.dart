import 'package:flutter/services.dart';

/// Service for receiving URLs shared from other apps via Share Extension
class ShareIntentService {
  ShareIntentService._();
  static final ShareIntentService instance = ShareIntentService._();

  static const _channel = MethodChannel('com.example.yommy/share');
  static const _appGroupId = 'group.com.example.yommy';
  static const _sharedKey = 'SharedURLs';

  /// Check for shared URLs and return them
  Future<List<String>> getSharedURLs() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getSharedURLs');
      return result?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      print('Error getting shared URLs: $e');
      return [];
    }
  }

  /// Clear processed URLs
  Future<void> clearSharedURLs() async {
    try {
      await _channel.invokeMethod('clearSharedURLs');
    } catch (e) {
      print('Error clearing shared URLs: $e');
    }
  }
}