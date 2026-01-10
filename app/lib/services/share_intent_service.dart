import 'dart:io';
import 'package:flutter/services.dart';

/// Service for receiving URLs shared from other apps
class ShareIntentService {
  ShareIntentService._();
  static final ShareIntentService instance = ShareIntentService._();

  static const _channel = MethodChannel('com.example.yommy/share');

  /// Get shared URL (works on both iOS and Android)
  Future<String?> getSharedUrl() async {
    try {
      if (Platform.isAndroid) {
        // Android: 直接URLを取得
        final result = await _channel.invokeMethod<String>('getSharedUrl');
        return result;
      } else if (Platform.isIOS) {
        // iOS: App Groups経由でURLリストを取得
        final result = await _channel.invokeMethod<List<dynamic>>('getSharedURLs');
        final urls = result?.map((e) => e.toString()).toList() ?? [];
        return urls.isNotEmpty ? urls.first : null;
      }
      return null;
    } catch (e) {
      print('Error getting shared URL: $e');
      return null;
    }
  }

  /// Get all shared URLs (iOS only, returns multiple if queued)
  Future<List<String>> getSharedURLs() async {
    try {
      if (Platform.isIOS) {
        final result = await _channel.invokeMethod<List<dynamic>>('getSharedURLs');
        return result?.map((e) => e.toString()).toList() ?? [];
      } else if (Platform.isAndroid) {
        final url = await getSharedUrl();
        return url != null ? [url] : [];
      }
      return [];
    } catch (e) {
      print('Error getting shared URLs: $e');
      return [];
    }
  }

  /// Clear processed URLs (iOS only)
  Future<void> clearSharedURLs() async {
    try {
      if (Platform.isIOS) {
        await _channel.invokeMethod('clearSharedURLs');
      }
      // Android は getSharedUrl() 時に自動クリア
    } catch (e) {
      print('Error clearing shared URLs: $e');
    }
  }
}