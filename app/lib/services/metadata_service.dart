import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';

/// Service for fetching metadata from URLs
class MetadataService {
  MetadataService._();
  static final MetadataService instance = MetadataService._();

  /// Fetch metadata from a URL
  Future<UrlMetadata> fetchMetadata(String url) async {
    try {
      // Ensure URL has scheme
      final normalizedUrl = _normalizeUrl(url);
      
      // Fetch metadata using metadata_fetch package
      final metadata = await MetadataFetch.extract(normalizedUrl);
      
      if (metadata == null) {
        return UrlMetadata(
          url: normalizedUrl,
          title: _extractTitleFromUrl(normalizedUrl),
        );
      }

      return UrlMetadata(
        url: normalizedUrl,
        title: metadata.title ?? _extractTitleFromUrl(normalizedUrl),
        description: metadata.description,
        thumbnailUrl: metadata.image,
        sourceName: _extractSourceName(normalizedUrl),
      );
    } catch (e) {
      // Return basic metadata on error
      return UrlMetadata(
        url: _normalizeUrl(url),
        title: _extractTitleFromUrl(url),
        sourceName: _extractSourceName(url),
      );
    }
  }

  /// Normalize URL (add https if missing)
  String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  /// Extract a title from URL when metadata is unavailable
  String _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      
      if (pathSegments.isNotEmpty) {
        // Use last path segment, cleaned up
        var title = pathSegments.last;
        // Remove file extensions
        title = title.replaceAll(RegExp(r'\.(html?|php|aspx?)$'), '');
        // Replace dashes/underscores with spaces
        title = title.replaceAll(RegExp(r'[-_]'), ' ');
        // Capitalize first letter
        if (title.isNotEmpty) {
          title = title[0].toUpperCase() + title.substring(1);
        }
        return title;
      }
      
      // Fall back to domain name
      return uri.host;
    } catch (e) {
      return 'Untitled';
    }
  }

  /// Extract source name from URL
  String? _extractSourceName(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      // Known sources mapping
      final knownSources = {
        'note.com': 'note',
        'zenn.dev': 'Zenn',
        'qiita.com': 'Qiita',
        'medium.com': 'Medium',
        'dev.to': 'DEV',
        'github.com': 'GitHub',
        'twitter.com': 'Twitter',
        'x.com': 'X',
        'youtube.com': 'YouTube',
        'youtu.be': 'YouTube',
        'amazon.co.jp': 'Amazon',
        'amazon.com': 'Amazon',
        'speakerdeck.com': 'Speaker Deck',
        'slideshare.net': 'SlideShare',
        'hatena.ne.jp': 'はてな',
        'hatenablog.com': 'はてなブログ',
      };

      // Check known sources
      for (final entry in knownSources.entries) {
        if (host.contains(entry.key)) {
          return entry.value;
        }
      }

      // Return domain without www
      return host.replaceFirst('www.', '');
    } catch (e) {
      return null;
    }
  }

  /// Validate if a string is a valid URL
  bool isValidUrl(String url) {
    try {
      final normalizedUrl = _normalizeUrl(url);
      final uri = Uri.parse(normalizedUrl);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Metadata extracted from a URL
class UrlMetadata {
  final String url;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? sourceName;

  const UrlMetadata({
    required this.url,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.sourceName,
  });

  @override
  String toString() =>
      'UrlMetadata(url: $url, title: $title, source: $sourceName)';
}
