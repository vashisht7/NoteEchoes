import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

enum WebKnowledgeStatus { answered, noReliableResult, offline }

class WebKnowledgeResult {
  final WebKnowledgeStatus status;
  final String answer;
  final String sourceTitle;
  final Uri? sourceUrl;

  const WebKnowledgeResult({
    required this.status,
    this.answer = '',
    this.sourceTitle = '',
    this.sourceUrl,
  });

  bool get hasAnswer =>
      status == WebKnowledgeStatus.answered && answer.trim().isNotEmpty;
}

/// A deliberately narrow, attributable web fallback for conversation mode.
/// It uses Wikipedia's public API and never turns an unverified search snippet
/// into an answer.
class WebKnowledgeService {
  WebKnowledgeService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<WebKnowledgeResult> answer(
    String question, {
    String languageCode = 'en',
  }) async {
    final query = _searchQuery(question);
    if (query.isEmpty) {
      return const WebKnowledgeResult(
        status: WebKnowledgeStatus.noReliableResult,
      );
    }

    final language = const {'en', 'te', 'hi'}.contains(languageCode)
        ? languageCode
        : 'en';
    final host = '$language.wikipedia.org';

    try {
      final searchUri = Uri.https(host, '/w/api.php', {
        'action': 'query',
        'list': 'search',
        'srsearch': query,
        'srlimit': '1',
        'format': 'json',
        'utf8': '1',
        'origin': '*',
      });
      final searchResponse = await _client
          .get(searchUri, headers: _headers)
          .timeout(const Duration(seconds: 6));
      if (searchResponse.statusCode != 200) {
        return const WebKnowledgeResult(status: WebKnowledgeStatus.offline);
      }

      final searchJson = jsonDecode(searchResponse.body);
      final searchQuery = searchJson is Map ? searchJson['query'] : null;
      final results = searchQuery is Map
          ? searchQuery['search'] as List?
          : null;
      if (results == null || results.isEmpty || results.first is! Map) {
        return const WebKnowledgeResult(
          status: WebKnowledgeStatus.noReliableResult,
        );
      }

      final first = Map<String, dynamic>.from(results.first as Map);
      final pageId = first['pageid']?.toString();
      final title = first['title']?.toString().trim() ?? '';
      if (pageId == null || title.isEmpty) {
        return const WebKnowledgeResult(
          status: WebKnowledgeStatus.noReliableResult,
        );
      }

      final extractUri = Uri.https(host, '/w/api.php', {
        'action': 'query',
        'prop': 'extracts',
        'pageids': pageId,
        'exintro': '1',
        'explaintext': '1',
        'exsentences': '4',
        'format': 'json',
        'utf8': '1',
        'origin': '*',
      });
      final extractResponse = await _client
          .get(extractUri, headers: _headers)
          .timeout(const Duration(seconds: 6));
      if (extractResponse.statusCode != 200) {
        return const WebKnowledgeResult(status: WebKnowledgeStatus.offline);
      }

      final extractJson = jsonDecode(extractResponse.body);
      final extractQuery = extractJson is Map ? extractJson['query'] : null;
      final pages = extractQuery is Map ? extractQuery['pages'] as Map? : null;
      final page = pages?[pageId] as Map?;
      final extract = page?['extract']?.toString().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final answer = extract?.trim() ?? '';
      if (answer.length < 40) {
        return const WebKnowledgeResult(
          status: WebKnowledgeStatus.noReliableResult,
        );
      }

      final articlePath = title.replaceAll(' ', '_');
      return WebKnowledgeResult(
        status: WebKnowledgeStatus.answered,
        answer: answer,
        sourceTitle: title,
        sourceUrl: Uri.https(host, '/wiki/$articlePath'),
      );
    } on TimeoutException {
      return const WebKnowledgeResult(status: WebKnowledgeStatus.offline);
    } on SocketException {
      return const WebKnowledgeResult(status: WebKnowledgeStatus.offline);
    } on http.ClientException {
      return const WebKnowledgeResult(status: WebKnowledgeStatus.offline);
    } on FormatException {
      return const WebKnowledgeResult(
        status: WebKnowledgeStatus.noReliableResult,
      );
    }
  }

  static const _headers = {
    'Accept': 'application/json',
    'User-Agent': 'NoteEchoes/2.11 (grounded conversation fallback)',
  };

  static String _searchQuery(String value) => value
      .trim()
      .replaceFirst(
        RegExp(
          r'^(?:please\s+)?(?:can\s+you\s+|could\s+you\s+|tell\s+me\s+|find\s+out\s+)?',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
