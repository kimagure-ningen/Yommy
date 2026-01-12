import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/// Service for local text summarization
class SummarizerService {
  SummarizerService._();
  static final SummarizerService instance = SummarizerService._();

  /// Generate a summary from HTML content
  Future<String> summarizeHtml(String htmlContent) async {
    try {
      // Parse HTML
      final document = html_parser.parse(htmlContent);
      
      // Extract text content
      final textContent = _extractTextContent(document);
      
      if (textContent.isEmpty) {
        return '要約を生成できませんでした。';
      }
      
      // Generate summary
      final summary = _generateSummary(textContent);
      
      return summary;
    } catch (e) {
      return '要約の生成中にエラーが発生しました。';
    }
  }

  /// Generate a summary from plain text
  Future<String> summarizeText(String text) async {
    try {
      if (text.isEmpty) {
        return '要約を生成できませんでした。';
      }
      
      final summary = _generateSummary(text);
      return summary;
    } catch (e) {
      return '要約の生成中にエラーが発生しました。';
    }
  }

  /// Extract meaningful text content from HTML document
  String _extractTextContent(dom.Document document) {
    // Remove script and style tags
    document.querySelectorAll('script').forEach((element) => element.remove());
    document.querySelectorAll('style').forEach((element) => element.remove());
    document.querySelectorAll('nav').forEach((element) => element.remove());
    document.querySelectorAll('header').forEach((element) => element.remove());
    document.querySelectorAll('footer').forEach((element) => element.remove());
    
    // Try to find main content areas
    final contentSelectors = [
      'article',
      'main',
      '[role="main"]',
      '.article-content',
      '.post-content',
      '.entry-content',
      '#content',
    ];
    
    for (final selector in contentSelectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        return elements.map((e) => e.text).join('\n');
      }
    }
    
    // Fallback to body content
    final body = document.querySelector('body');
    return body?.text ?? '';
  }

  /// Generate summary using extractive method
  String _generateSummary(String text) {
    // Clean and normalize text
    final cleaned = _cleanText(text);
    
    // Split into sentences
    final sentences = _splitIntoSentences(cleaned);
    
    if (sentences.isEmpty) {
      return '要約を生成できませんでした。';
    }
    
    // Score sentences
    final scoredSentences = _scoreSentences(sentences, cleaned);
    
    // Get top sentences (max 5)
    final topCount = sentences.length < 5 ? sentences.length : 5;
    final topSentences = scoredSentences.take(topCount).toList();
    
    // Sort by original order
    topSentences.sort((a, b) => 
      sentences.indexOf(a.sentence).compareTo(sentences.indexOf(b.sentence))
    );
    
    // Build summary
    final summary = topSentences.map((s) => s.sentence).join(' ');
    
    // Add ellipsis if truncated
    if (sentences.length > topCount) {
      return '$summary...';
    }
    
    return summary;
  }

  /// Clean and normalize text
  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single
        .replaceAll(RegExp(r'\n+'), '\n') // Multiple newlines to single
        .trim();
  }

  /// Split text into sentences
  List<String> _splitIntoSentences(String text) {
    // Simple sentence splitting (can be improved)
    final sentences = text.split(RegExp(r'[。\.！!？?]\s*'));
    
    return sentences
        .where((s) => s.trim().length > 10) // Filter very short sentences
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Score sentences based on importance
  List<ScoredSentence> _scoreSentences(List<String> sentences, String fullText) {
    final scoredSentences = <ScoredSentence>[];
    
    // Calculate word frequencies
    final wordFreq = _calculateWordFrequencies(fullText);
    
    for (final sentence in sentences) {
      var score = 0.0;
      
      // Score based on word frequencies
      final words = sentence.toLowerCase().split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.length > 3) { // Ignore very short words
          score += wordFreq[word] ?? 0;
        }
      }
      
      // Normalize by sentence length
      score = score / words.length;
      
      // Boost for sentences with numbers (often important facts)
      if (RegExp(r'\d+').hasMatch(sentence)) {
        score *= 1.2;
      }
      
      // Boost for sentences in first paragraph (often important)
      if (sentences.indexOf(sentence) < 3) {
        score *= 1.3;
      }
      
      scoredSentences.add(ScoredSentence(sentence, score));
    }
    
    // Sort by score (descending)
    scoredSentences.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredSentences;
  }

  /// Calculate word frequencies
  Map<String, double> _calculateWordFrequencies(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final frequencies = <String, int>{};
    
    for (final word in words) {
      if (word.length > 3) { // Ignore short words
        frequencies[word] = (frequencies[word] ?? 0) + 1;
      }
    }
    
    // Normalize frequencies
    final maxFreq = frequencies.values.isEmpty 
        ? 1 
        : frequencies.values.reduce((a, b) => a > b ? a : b);
    
    return frequencies.map(
      (word, freq) => MapEntry(word, freq / maxFreq),
    );
  }
}

/// Sentence with importance score
class ScoredSentence {
  final String sentence;
  final double score;

  ScoredSentence(this.sentence, this.score);
}